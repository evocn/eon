// Everett
// Render
// Alex Hartford
// June 2023

render :: (game: Game) {
    next_bind_id = 0;

    ////////////////////////////////////////////////////////////////////////////////
    // Shadow pass, drawing to the depth buffer.
    {
        start_drawing_to_depth_buffer(shadow_map.depth_buffer);

        render_scene_to_depth_buffer(game);
    }

    ////////////////////////////////////////////////////////////////////////////////
    // Main Pass
    {
        start_drawing_to_framebuffer(framebuffer);
        {
            if settings.line_mode
                glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

            render_scene(game);

            if program_state.mode == .EDITOR {
                render_editor_overlays(game);
            }

            glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

        }
        draw_buffer_to_the_screen(framebuffer.color_buffer, 0, 0, xx window_width, xx window_height);
    }

    ////////////////////////////////////////////////////////////////////////////////
    // Interface
    {
        // Draw Text
        glDisable(GL_DEPTH_TEST);
        defer glEnable(GL_DEPTH_TEST);

        shader := use_text_shader();
        defer disable_shaders();

        font, found := table_find(*fonts, "Header");
        for debug.lines {
            draw_text(shader, font, it, 10, window_height - 10 - cast(float)(it_index + 1) * font.height, 1.0);
        }
    }


    ////////////////////////////////////////////////////////////////////////////////
    // Debug Stuff
    {
        if settings.shadow_debug {
            draw_buffer_to_the_screen(shadow_map.depth_buffer.buffer, 0, 0, xx (window_height / 4), xx (window_height / 4));
        }
    }

    print_gl_errors();
}

render_scene :: (game: Game) {
    view_frustum := calculate_view_frustum(program_state.camera.projection, program_state.camera.view);

    {
        // Draw Entities
        shader := use_main_shader();
        defer disable_shaders();

        entities_drawn := 0;
        for entity : game.entities {
            if !entity_is_inside_frustum(view_frustum, entity) {
                continue;
            }

            draw_entity(entity, shader);
            entities_drawn += 1;
        }

        set_int(shader, "animated", 0);

        screen_print(tprint("Drawn: %", entities_drawn));
    }

    {
        // Draw Plane
        shader := use_main_shader();
        defer disable_shaders();

        draw_ground_plane(100, shader);
    }

    // Draw Skybox
    {
        shader := use_skybox_shader();
        defer disable_shaders();

        draw_skybox(shader);
    }
}



render_scene_to_depth_buffer :: (game: Game) {

    {
        // Draw Entities

        shader := use_depth_shader();
        defer disable_shaders();

        for entity : game.entities {
            draw_entity(entity, shader);
        }
    }

    {
        // Draw Plane

        shader := use_depth_shader();
        defer disable_shaders();

        draw_ground_plane(100, shader);
    }
}


////////////////////////////////////////////////////////////////////////////////
// Editor Rendering Overlays

render_editor_overlays :: (game: Game) {
    {
        // Draw highlighted things
        shader := use_highlight_shader();
        defer disable_shaders();

        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
        defer glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

        if editor.selected_entity != -1 {
            draw_entity(game.entities[editor.selected_entity], shader);
        }

        if settings.draw_bounding_boxes {
            for entity : game.entities {
                draw_bounding_box(entity, shader);
            }
        }
    }
}
