// Everett
// Main
// Alex Hartford
// June 2023

VERSION :: 1;

window : *SDL_Window;
gl_context : *SDL_GLContext;
imgui_context : *ImGui.ImGuiContext;

default_window_width  :: 1920;
default_window_height :: 1080;

default_framebuffer_width  :: 1920;
default_framebuffer_height :: 1080;

window_width  := default_window_width;
window_height := default_window_height;
aspect_ratio  : float = 1.8;

running : bool;

entities_path :: "data";
meshes_path :: "assets/meshes";

forever_pool: Flat_Pool;

entity_pool : Flat_Pool;

mesh_pool   : Flat_Pool;
mesh_storage: Bucket_Array(Mesh, 20);
mesh_catalogue : Table(string, *Mesh);

// @TODO: We should probably keep primitives like this one that we'll draw a lot in a structure together.
quad : Quad;
cube : Cube;

fonts : Table(string, Font);

textures : Table(string, Texture);

// Program-Level State
//

program_state : struct {
    mode : Program_Mode = .VIEW;
    prior_mode : Program_Mode = .EDITOR;

    paused : bool;

    current_level_name := "all.entities";

    imgui_capturing_mouse    : bool;
    imgui_capturing_keyboard : bool;

    framerate : float;
}

settings : struct {
    line_mode           : bool;
    draw_bounding_boxes : bool;
    shadow_debug        : bool;

    default_camera_position :: Vector3.{0, 10, 10};
    default_camera_angles   :: Vector3.{0, 1.0, 0};
}

editor : struct {
    selected_entity := -1;
    selected_mesh := "";
}

// Render-Level State
//

render_context : struct {
    using shaders : struct {
        basic_shader     : Shader;
        main_shader      : Shader;
        skybox_shader    : Shader;

        screen_shader    : Shader;
        text_shader      : Shader;

        depth_shader     : Shader;

        highlight_shader : Shader;
    }

    directional_light : Directional_Light = .{direction = Vector3.{y=-1}};
    skybox : Skybox;
}

// Main
//

pose : Skeleton_Pose;
anim : Sampled_Animation;
animation_time : float;
animation_speed_in_fps : float;

main :: () {
    defer print("Program exited successfully.\n");

    init_result := init();
    assert(init_result);

    // Gameplay structures setup
    entities : [..] *Entity;

    success := load_entities(*entities, program_state.current_level_name);
    assert(success);

    // The Game Loop
    delta_time, last_frame := 0.0;
    running = true;
    while running {
        reset_temporary_storage();
        array_reset(*debug.lines);
        current_time := cast(float32)seconds_since_init();
        delta_time = current_time - last_frame;
        last_frame = current_time;

        // Handle Events
        handle_events();

        resolve_camera_inputs(delta_time);

        // Simulate
        if program_state.mode == .GAME {
            simulate(*entities, delta_time);
        }

        screen_print(tprint("FPS: %", FormatFloat.{value=1.0 / delta_time, trailing_width=0}));
        screen_print(tprint("Mode: %", program_state.mode));

        reset_to_bind_pose(*pose);

        sample_animation(anim, animation_time, *pose, .LINEAR);

        // Increment animation time
        animation_time += delta_time * animation_speed_in_fps;
        animation_time = fmod_cycling(animation_time, xx anim.sample_count);

        // We transpose the result because OpenGL stores matrices in column-major
        generate_skinning_matrices(*pose, transpose_result = true);


        // Render
        render(entities);

        // Editor
        if program_state.mode == .EDITOR {
            update_and_draw_editor(*entities);
            ImGui_ImplSdl_RenderDrawLists(ImGui.GetDrawData());
        }
        SDL_GL_SwapWindow(window);

        SDL_Delay(10);
    }

    array_reset(*debug.lines);

    bucket_array_reset(*mesh_storage);
    reset(*mesh_pool, overwrite_memory=true);

    array_reset(*entities);
    reset(*entity_pool, overwrite_memory=true);

    reset(*forever_pool, overwrite_memory=true);

    ImGui_ImplSdl_Shutdown();
    ImGui.DestroyContext(imgui_context);
    SDL_GL_DeleteContext(gl_context);
    SDL_DestroyWindow(window);
    SDL_Quit();

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

#import "gltf_parser";

#import "stb_image";
#import "freetype255";

#import "SDL";
#import "GL";
ImGui :: #import "ImGui";


////////////////////////////////////////////////////////////////////////////////

#load "utils.jai";
#load "init.jai";
#load "imgui_init.jai";
#load "input.jai";
#load "camera.jai";
#load "collision.jai";
       
#load "program_mode.jai";
       
#load "editor.jai";
#load "undo.jai";
#load "gizmos.jai";
       
#load "debug.jai";
       
       
#load "entity.jai";
#load "serialization.jai";
       
       
#load "simulate.jai";
#load "body.jai";
       
       
#load "render.jai";
#load "primitives.jai";
#load "parse_utils.jai";
#load "mesh.jai";
#load "animation.jai";
       
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
       
#load "font.jai";
