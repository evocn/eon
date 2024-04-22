// Everett
// Main
// Alex Hartford
// March 2024

/*
    This is the Everett Project
    Working towards a 3D Game Prototype of the Dark Night of the Soul idea.

    Todo:
    * Multiple animations per entity, more developed animation controller system for movie.
    * Fix up shadow frustum generation, make it work with the sun, etc.
    * Fix up bounding box generation ( Should be able to just make a big approximation and call it a day.)
    * Water
    * Distance Fog

    * Hair

    Nice to have:
    * Visualization of frustums
    * Shadow Cascades
    * Heightmap LOD with tessellation.
      * Kriging system?
    * Volumetric Fog?
*/

////////////////////////////////////////////////////////////////////////////////

VERSION :: 1;

////////////////////////////////////////////////////////////////////////////////
// Window State

window : *SDL_Window;
gl_context : *SDL_GLContext;
imgui_context : *ImGui.ImGuiContext;

default_window_width  :: 2560;
default_window_height :: 1440;

default_framebuffer_width  :: 2560;
default_framebuffer_height :: 1440;

window_width  := default_window_width;
window_height := default_window_height;

GAME_ASPECT_RATIO :: 16.0 / 9.0;
aspect_ratio := GAME_ASPECT_RATIO;

////////////////////////////////////////////////////////////////////////////////

entities_path   :: "data";
meshes_path     :: "assets/meshes";
animations_path :: "assets/animations";
heightmaps_path :: "assets/heightmaps";

forever_pool: Flat_Pool;

entity_pool : Flat_Pool;

mesh_pool   : Flat_Pool;
mesh_storage: Bucket_Array(Mesh, 20);
mesh_catalogue : Table(string, *Mesh);

animation_pool   : Flat_Pool;
animation_storage: Bucket_Array(Sampled_Animation, 20);
animation_catalogue : Table(string, *Sampled_Animation);

// @TODO: We should probably keep primitives like this one that we'll draw a lot in a structure together.
quad : Quad;
cube : Cube;
sphere : Sphere;

fonts : Table(string, Font);

textures : Table(string, Texture);

// Program-Level State
//

program_state : struct {
    running : bool;

    mode : Program_Mode = .VIEW;
    prior_mode : Program_Mode = .EDITOR;

    paused : bool;

    current_level_name := "all.entities";

    imgui_capturing_mouse    : bool;
    imgui_capturing_keyboard : bool;

    framerate : float;

    camera : *Camera;

    editor_camera : *Camera;
    game_camera   : *Camera;

    camera_system : Camera_System;
}

settings : struct {
    shadows             : bool = true;
    line_mode           : bool;
    normals_mode        : bool;
    draw_bounding_boxes : bool;
    framebuffer_debug   : bool;
    skeleton_debug      : bool;
    frustum_culling     : bool = true;

    DEFAULT_CAMERA_ORIGIN :: Vector3.{0, 1, 10};
    DEFAULT_CAMERA_ANGLES :: Vector3.{0, 0, 0};
}

editor : struct {
    selected_entity := -1;
    selected_mesh := "";
}

input: Input;

// Render-Level State
//

render_context : struct {
    using shaders : struct {
        basic_shader     : Shader;
        main_shader      : Shader;
        terrain_shader   : Shader;
        skybox_shader    : Shader;
        highlight_shader : Shader;

        depth_shader     : Shader;

        text_shader      : Shader;
        screen_shader    : Shader;
        post_processing_shader : Shader;
    }

    directional_light : Directional_Light = .{direction = Vector3.{y=-1}};
    skybox : Skybox;
    sun : Celestial_Body;
}


////////////////////////////////////////////////////////////////////////////////
// Main

ubo : GLuint;
g_line_vao, g_line_vbo : GLuint;

main :: () {
    defer print("Program exited successfully.\n");

    ////////////////////////////////////////////////////////////////////////////////
    // Program structure Initialization
    {
        success := init();
        assert(success);

        // Initialize Camera System
        {
            a: Allocator;
            a.proc = flat_pool_allocator_proc;
            a.data = *program_state.camera_system.camera_pool;

            program_state.camera_system.cameras.allocator = a;

            // Editor Camera
            {
                new_camera := cast(*Camera)New(Camera_Flying,, a);
                array_add(*program_state.camera_system.cameras, new_camera);

                program_state.editor_camera = new_camera;

                set_camera(new_camera, settings.DEFAULT_CAMERA_ORIGIN, settings.DEFAULT_CAMERA_ANGLES);
            }

            // Game Camera
            {
                new_camera := cast(*Camera)New(Camera_Walking,, a);
                array_add(*program_state.camera_system.cameras, new_camera);

                program_state.game_camera = new_camera;

                set_camera(new_camera, Game.DEFAULT_CAMERA_ORIGIN, Game.DEFAULT_CAMERA_ANGLES);
            }

            program_drive_free_camera();
        }

        switch_mode(program_state.mode);
    }

    ////////////////////////////////////////////////////////////////////////////////
    // Game structure Initialization
    game : Game;

    {
        // Load Entities from the entities file.
        {
            success := load_entities(*game.entities, program_state.current_level_name);
            assert(success);
        }

        // Load Heightmap from a file.
        {
            success := load_terrain_from_heightmap_file(*game.terrain, "lake.png");
            assert(success);
        }
    }

    // Create uniform buffer object
    {
        // @TODO: This will be necessary if we want to pass more than one UBO.
        /*
        big_data_uniform_index := glGetUniformBlockIndex (g_mesh_shader, "Big_Data");
        glUniformBlockBinding (g_mesh_shader, big_data_uniform_index, GL_BIG_DATA_UNIFORM_BINDING);
        */

        // Check if we can store enough data for the skinning information in a shader uniform block.
        uniform_block_size : s32;
        glGetIntegerv (GL_MAX_UNIFORM_BLOCK_SIZE, *uniform_block_size);
        assert (uniform_block_size >= MAX_JOINTS * size_of (Matrix4),
            "OpenGL implementation does not allow storing more than % bytes in uniform block, but we need at least % for skinning information. Recompile the program with a smaller MAX_JOINTS value.",
            uniform_block_size, MAX_JOINTS * size_of(Matrix4));

        glGenBuffers(1, *ubo);
        glBindBuffer(GL_UNIFORM_BUFFER, ubo);
        glBufferData(GL_UNIFORM_BUFFER, size_of(Matrix4) * MAX_JOINTS, null, GL_DYNAMIC_DRAW);
        glBindBuffer(GL_UNIFORM_BUFFER, 0);
        glBindBufferBase(GL_UNIFORM_BUFFER, 0, ubo);
    }

    // Create line objects. We have a vertex buffer that we fill
    // every time we want to draw a line.
    {
        glGenVertexArrays (1, *g_line_vao);
        glBindVertexArray (g_line_vao);

        glGenBuffers(1, *g_line_vbo);
        glBindBuffer(GL_ARRAY_BUFFER, g_line_vbo);
        glBufferData(GL_ARRAY_BUFFER, size_of(Vector3) * 2, null, GL_DYNAMIC_DRAW);

        glEnableVertexAttribArray(0);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, size_of(Vector3), cast(*void)0);

        glBindVertexArray(0);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
    }

    ////////////////////////////////////////////////////////////////////////////////
    // The Loop

    delta_time, last_frame := 0.0;
    program_state.running = true;
    while program_state.running {
        ////////////////////////////////////////////////////////////////////////////////
        // Frame Startup
        {
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Events / Input
        {
            handle_events_and_gather_input();

            resolve_camera_inputs(program_state.camera, delta_time);

            screen_print(tprint("Camera: %", program_state.camera.kind));
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Simulate
        {
            if !program_state.paused {
                //if program_state.mode == .GAME {
                    simulate(*game, delta_time);
                //}
            }
        }

        // Render
        ////////////////////////////////////////////////////////////////////////////////
        {
            screen_print(tprint("FPS: %", FormatFloat.{value=1.0 / delta_time, trailing_width=0}));
            screen_print(tprint("Mode: %", program_state.mode));

            render(game);

            // Editor
            if program_state.mode == .EDITOR {
                update_and_draw_editor(*game);
                ImGui_ImplSdl_RenderDrawLists(ImGui.GetDrawData());
            }
            SDL_GL_SwapWindow(window);
        }

        // Wait a little while, since this will make most GPUs spin needlessly!
        SDL_Delay(5);

        ////////////////////////////////////////////////////////////////////////////////
        // Frame Cleanup
        {
            current_time := cast(float32)seconds_since_init();
            delta_time = current_time - last_frame;
            last_frame = current_time;

            reset_temporary_storage();

            array_reset(*debug.lines);
        }
    }

    // Program Shutdown
    {
        array_reset(*debug.lines);

        bucket_array_reset(*mesh_storage);
        reset(*mesh_pool, overwrite_memory=true);

        array_reset(*game.entities);
        reset(*entity_pool, overwrite_memory=true);

        reset(*forever_pool, overwrite_memory=true);

        ImGui_ImplSdl_Shutdown();
        ImGui.DestroyContext(imgui_context);
        SDL_GL_DeleteContext(gl_context);
        SDL_DestroyWindow(window);
        SDL_Quit();
    }

    #if DEBUG_MEMORY then report_memory_leaks();
}

DEBUG_MEMORY :: true;

using Basic :: #import "Basic"()(MEMORY_DEBUGGER=DEBUG_MEMORY);
#import "String";
#import "System"; // get_path_of_running_executable()
#import "Math";
#import "Hash_Table";

#import "Flat_Pool";
#import "Bucket_Array";

#import "File";
#import "Text_File_Handler";

STBI_ONLY_PNG :: 1; // @TODO: Make sure this works!
#import "stb_image";

#import "freetype255";

#import "SDL";
#import "GL";
ImGui :: #import "ImGui";

////////////////////////////////////////////////////////////////////////////////

#load "utils.jai";
#load "init.jai";
#load "input.jai";
#load "camera.jai";

#load "font.jai";

#load "program_state.jai";

#load "editor.jai";
#load "editor_imgui_init.jai";
#load "editor_controls.jai";
#load "editor_undo.jai";
#load "editor_gizmos.jai";

#load "game.jai";
#load "simulate.jai";
#load "entity.jai";
#load "serialization.jai";
#load "character_controller.jai";

#load "debug.jai";

#load "render.jai";
#load "primitives.jai";
#load "parse_utils.jai";
#load "mesh.jai";

#load "animation.jai";
#load "animation_controller.jai";

#load "color.jai";
#load "light.jai";
#load "frustum.jai";

#load "shader.jai";
#load "texture.jai";
#load "framebuffer.jai";
#load "depthbuffer.jai";

#load "skybox.jai";
#load "shadow.jai";
#load "water.jai";

#load "celestial_body.jai";
#load "terrain.jai";
