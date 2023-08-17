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

window_width  := default_window_width;
window_height := default_window_height;
aspect_ratio  : float = 1.8;

running : bool;

// @TODO: This should be a bucket array.
meshes : Table(string, *Skinned_Mesh);

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

    current_level_name := "level1.entities";

    imgui_capturing_mouse    := false;
    imgui_capturing_keyboard := false;

    framerate : float;
}

settings : struct {
    line_mode := false;

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
        animation_shader : Shader;
        skybox_shader    : Shader;

        screen_shader    : Shader;
        text_shader      : Shader;

        depth_shader     : Shader;
    }

    directional_light : Directional_Light = .{direction = Vector3.{y=-1}};
    skybox : Skybox;
}

// Main
//

main :: () {
    defer print("Program exited successfully.\n");

    init_result := init();
    assert(init_result);


    // Gameplay structures setup
    entities : [..] *Entity;

    success := load_entities(*entities, program_state.current_level_name);
    assert(success);


    // The Game Loop
    dt, last_frame := 0.0;
    running = true;
    while running {
        reset_temporary_storage();
        array_reset(*debug.lines);
        current_time := cast(float32)get_time();
        dt = current_time - last_frame;
        last_frame = current_time;

        // Handle Events
        handle_events();
        resolve_camera_inputs(dt);

        // Simulate
        if program_state.mode == .GAME {
            if !program_state.paused {
            }
        }

        screen_print(tprint("Mode: %\n", program_state.mode));

        /*
        reset_to_bind_pose(*pose);
        sample_animation(anim, animation_time, *pose, .LINEAR);

        // Increment animation time
        animation_time += dt * animation_speed_in_fps;
        animation_time = fmod_cycling(animation_time, xx anim.sample_count);

        // We transpose the result because OpenGL stores matrices in column-major
        generate_skinning_matrices(*pose, transpose_result = true);
        */

        // Render
        render(entities);

        // Editor
        if program_state.mode == .EDITOR {
            update_and_draw_editor(*entities);
            ImGui_ImplSdl_RenderDrawLists(ImGui.GetDrawData());
        }
        SDL_GL_SwapWindow(window);

        SDL_Delay(1);
    }

    ImGui_ImplSdl_Shutdown();
    ImGui.DestroyContext(imgui_context);
    SDL_GL_DeleteContext(gl_context);
    SDL_DestroyWindow(window);
    SDL_Quit();
}

using Basic :: #import "Basic";
#import "String";
#import "System"; // get_path_of_running_executable()
#import "Math";
#import "Hash_Table";

#import "File";
#import "Text_File_Handler";
#import "stb_image";
#import "freetype255";

#import "SDL";
#import "GL";
ImGui :: #import "ImGui";
