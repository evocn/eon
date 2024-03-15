// Everett
// Render
// Alex Hartford
// June 2023

render :: (entities : [..] *Entity) {
    next_bind_id = 0;

    {
        // Shadow pass, drawing to the depth buffer.
        start_drawing_to_depth_buffer(shadow_map.depth_buffer);

        render_scene_to_depth_buffer(entities);

        if settings.shadow_debug {
            draw_buffer_to_the_screen(shadow_map.depth_buffer.buffer);
            return;
        }
    }

    {
        // Render Scene to the framebuffer.
        start_drawing_to_framebuffer(framebuffer);

        if settings.line_mode
            glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

        render_scene(entities);

        glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

        draw_buffer_to_the_screen(framebuffer.color_buffer);
    }

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

    print_gl_errors();
}

render_scene :: (entities : [..] *Entity) {
    view_frustum := calculate_view_frustum(camera.projection, camera.view);

    {
        // Draw Entities
        shader := use_main_shader();
        defer disable_shaders();

        entities_drawn := 0;
        for entities {
            if !entity_is_inside_frustum(view_frustum, it) {
                continue;
            }

            draw_entity(it, shader);
            entities_drawn += 1;
        }

        set_int(shader, "animated", 0);

        screen_print(tprint("Drawn: %\n", entities_drawn));
    }

    {
        // Draw highlighted things
        shader := use_highlight_shader();
        defer disable_shaders();

        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
        defer glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

        if editor.selected_entity != -1 {
            draw_entity(entities[editor.selected_entity], shader);
        }

        if settings.draw_bounding_boxes {
            for entities {
                draw_bounding_box(it, shader);
            }
        }
    }


    {
        // Draw Plane
        shader := use_main_shader();
        defer disable_shaders();

        draw_ground_plane(20, shader);
    }

    // Draw Skybox
    {
        shader := use_skybox_shader();
        defer disable_shaders();

        draw_skybox(shader);
    }
}

render_scene_to_depth_buffer :: (entities : [..] *Entity) {

    {
        // Draw Entities

        shader := use_depth_shader();
        defer disable_shaders();

        for entities {
            draw_entity(it, shader);
        }
    }

    {
        // Draw Plane

        shader := use_depth_shader();
        defer disable_shaders();

        draw_ground_plane(20, shader);
    }
}
