// Everett
// Input
// Alex Hartford
// June 2023

Button :: struct {
    just_pressed : bool;
    is_down : bool;
}

press :: (button: *Button) {
    button.just_pressed = true;
    button.is_down = true;
}

release :: (button: *Button) {
    button.just_pressed = false;
    button.is_down = false;
}

update :: (button: *Button) {
    if button.just_pressed {
        button.just_pressed = false;
        button.is_down = true;
    }
}

post_frame_update :: (input: *Input) {
    update(*input.up);
    update(*input.left);
    update(*input.down);
    update(*input.right);
    update(*input.north);
    update(*input.south);
    update(*input.east);
    update(*input.west);
    update(*input.start);
    update(*input.select);

    update(*input.left_mouse);
    update(*input.right_mouse);
}

Input :: struct {
    up      : Button;
    left    : Button;
    down    : Button;
    right   : Button;

    north   : Button;
    south   : Button;
    east    : Button;
    west    : Button;

    start   : Button;
    select  : Button;

    mouse_position : Vector2;
    left_mouse : Button;
    right_mouse: Button;
}

handle_events_and_gather_input :: () {
    event : SDL_Event;
    while SDL_PollEvent(*event) {
        ImGui_ImplSdl_ProcessEvent(*event);

        if event.type == {
            case SDL_QUIT;
                program_state.running = false;

            case SDL_KEYUP;
                if program_state.imgui_capturing_keyboard then continue;

                     if event.key.keysym.sym == SDLK_w       release(*input.up);
                else if event.key.keysym.sym == SDLK_a       release(*input.left);
                else if event.key.keysym.sym == SDLK_s       release(*input.down);
                else if event.key.keysym.sym == SDLK_d       release(*input.right);

                else if event.key.keysym.sym == SDLK_LSHIFT  release(*input.west);
                else if event.key.keysym.sym == SDLK_j       release(*input.south);
                else if event.key.keysym.sym == SDLK_k       release(*input.north);
                else if event.key.keysym.sym == SDLK_l       release(*input.east);

            case SDL_KEYDOWN;
                if program_state.imgui_capturing_keyboard then continue;

                if event.key.keysym.sym == SDLK_ESCAPE {
                    program_state.running = false;
                }

                // Settings
                if event.key.keysym.sym == SDLK_l {
                    settings.line_mode = !settings.line_mode;
                }

                if event.key.keysym.sym == SDLK_b {
                    settings.draw_bounding_boxes = !settings.draw_bounding_boxes;
                }

                if event.key.keysym.sym == SDLK_g {
                    settings.shadow_debug = !settings.shadow_debug;
                }

                if event.key.keysym.sym == SDLK_0 {
                    program_state.paused = !program_state.paused;
                }

                if event.key.keysym.sym == SDLK_1 
                    switch_mode(.GAME);

                if event.key.keysym.sym == SDLK_2
                    switch_mode(.EDITOR);

                if event.key.keysym.sym == SDLK_3
                    switch_mode(.VIEW);

                // Main Program Inputs
                {
                    if event.key.repeat != 0 return;

                         if event.key.keysym.sym == SDLK_w       press(*input.up);
                    else if event.key.keysym.sym == SDLK_a       press(*input.left);
                    else if event.key.keysym.sym == SDLK_s       press(*input.down);
                    else if event.key.keysym.sym == SDLK_d       press(*input.right);

                    else if event.key.keysym.sym == SDLK_LSHIFT  press(*input.west);
                    else if event.key.keysym.sym == SDLK_j       press(*input.south);
                    else if event.key.keysym.sym == SDLK_k       press(*input.north);
                    else if event.key.keysym.sym == SDLK_l       press(*input.east);

                    else if event.key.keysym.sym == SDLK_SPACE   press(*input.start);
                    else if event.key.keysym.sym == SDLK_ESCAPE  press(*input.select);
                }

            case SDL_MOUSEBUTTONDOWN;
                if program_state.imgui_capturing_mouse return;

                // Main Program Inputs
                {
                    if event.button.button == SDL_BUTTON_LEFT   press(*input.left_mouse);
                    if event.button.button == SDL_BUTTON_RIGHT  press(*input.right_mouse);
                }

            case SDL_MOUSEBUTTONUP;
                if program_state.imgui_capturing_mouse return;

                // Main Program Inputs
                {
                    if event.button.button == SDL_BUTTON_LEFT   release(*input.left_mouse);
                    if event.button.button == SDL_BUTTON_RIGHT  release(*input.right_mouse);
                }

            case SDL_MOUSEMOTION;
                if program_state.imgui_capturing_mouse return;

                // @TODO: Actually use these inputs instead of the per-frame ad-hoc thing
                /*
                // Main Program Inputs
                {
                    input.mouse_position.x = cast(int)(event.motion.x * (cast(float)PIXEL_WIDTH  / render_context.window_width));
                    input.mouse_position.y = PIXEL_HEIGHT - cast(int)(event.motion.y * (cast(float)PIXEL_HEIGHT / render_context.window_height)) - 1;
                }
                */


            case SDL_WINDOWEVENT;
                if event.window.event == SDL_WINDOWEVENT_SIZE_CHANGED {
                    window_width  = event.window.data1;
                    window_height = event.window.data2;

                    // @TODO: Aspect Ratio Controls with letterboxing
                    /*
                    viewport_height = window_height;
                    viewport_width  = cast(s32)(viewport_height * GAME_ASPECT_RATIO);
                    */
                }
        }
    }
}
