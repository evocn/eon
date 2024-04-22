// Everett
// Render
// Alex Hartford
// June 2023

light_direction : Vector3;

render :: (game: Game) {
    next_bind_id = 0;

    light_direction = get_light_direction(render_context.sun);

    ////////////////////////////////////////////////////////////////////////////////
    // Shadow pass, drawing to the depth buffer.
    {
        start_drawing_to_depth_buffer(shadow_map.depth_buffer);

        if settings.shadows {
            render_scene_to_depth_buffer(game);
        }
    }

    ////////////////////////////////////////////////////////////////////////////////
    // Main Pass
    {
        start_drawing_to_framebuffer(framebuffer);
        {
            if settings.line_mode {
                glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
            }
            defer glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

            render_scene(game);

            if program_state.mode == .EDITOR ||
               program_state.mode == .VIEW
            {
                render_editor_overlays(game);
            }

        }

        ////////////////////////////////////////////////////////////////////////////////
        // Debug stuff to put in the scene
        {
            // Animations
            if settings.skeleton_debug {
                shader := use_basic_shader();
                defer disable_shaders();

                for entity : game.entities {
                    model := model_matrix(entity.transform);

                    glDisable(GL_DEPTH_TEST);
                    defer glEnable(GL_DEPTH_TEST);

                    draw_pose(entity.pose, model, pink);
                }
            }

            draw_grid();
        }

        draw_framebuffer_to_screen_with_post_processing(framebuffer);
    }

    ////////////////////////////////////////////////////////////////////////////////
    // Interface
    {
        // Draw Text
        glDisable(GL_DEPTH_TEST);
        defer glEnable(GL_DEPTH_TEST);

        shader := use_text_shader();
        defer disable_shaders();
        {
            font, found := table_find(*fonts, "Header");
            for debug.lines {
                draw_text(shader, font, it, 10, window_height - 10 - cast(float)(it_index + 1) * font.height, 1.0);
            }
        }
    }


    ////////////////////////////////////////////////////////////////////////////////
    // Debug Stuff to draw on top of all the framebuffers
    {
        // Shadows
        if settings.framebuffer_debug {

            draw_buffer_to_the_screen(shadow_map.depth_buffer.buffer, 0, 0, xx (window_height / 3), xx (window_height / 3));

            draw_buffer_to_the_screen(framebuffer.depth_buffer, xx (window_width / 3), 0, xx (window_width / 3), xx (window_height / 3));
        }
    }

    print_gl_errors();
}

render_scene :: (game: Game) {
    view_frustum := calculate_view_frustum(program_state.camera.projection, program_state.camera.view);

    // Draw Entities
    {
        shader := use_main_shader();
        defer disable_shaders();

        set_vec3(shader, "light_direction", light_direction);

        set_int(shader, "normals_mode", xx settings.normals_mode);

        entities_drawn := 0;
        for entity : game.entities {
            if settings.frustum_culling {
                if !entity_is_inside_frustum(view_frustum, entity) {
                    continue;
                }
            }

            draw_entity(entity, shader);
            entities_drawn += 1;
        }

        screen_print(tprint("Drawn: %", entities_drawn));
    }

    // Draw Terrain
    {
        shader := use_terrain_shader();
        defer disable_shaders();

        set_vec3(shader, "light_direction", light_direction);

        set_int(shader, "normals_mode", xx settings.normals_mode);

        draw_terrain(game.terrain, shader);
    }

    // Celestial Bodies
    {
        shader := use_basic_shader();
        defer disable_shaders();

        draw(render_context.sun, shader);
    }

    // Draw Skybox
    {
        shader := use_skybox_shader();
        defer disable_shaders();

        draw_skybox(shader);
    }
}



render_scene_to_depth_buffer :: (game: Game) {
    // Draw Entities
    {
        shader := use_depth_shader();
        defer disable_shaders();

        for entity : game.entities {
            draw_entity(entity, shader);
        }
    }

    // Draw Terrain
    {
        shader := use_depth_shader();
        defer disable_shaders();

        draw_terrain(game.terrain, shader);
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

////////////////////////////////////////////////////////////////////////////////
// Taken from the skeletal animation sample in the jai beta

draw_grid :: () {
    // Draw grid
    for i : -10..10
        draw_line(xyz (xx i, 0, -10), xyz (xx i, 0, 10), black);
    for i : -10..10
        draw_line(xyz (-10, 0, xx i), xyz (10, 0, xx i), black);

    glLineWidth(10);
        // Draw coordinate axes
        draw_line (.{}, .{x=1}, .{x=1, w=1});
        draw_line (.{}, .{y=1}, .{y=1, w=1});
        draw_line (.{}, .{z=1}, .{z=1, w=1});
    glLineWidth(5);
}

draw_pose :: (pose : Skeleton_Pose, overall_offset_transform : Matrix4, color : Vector4)
{
    for * joint : pose.joints
    {
        parent_transform : Matrix4 = ---;
        parent := joint.parent;
        if parent
            parent_transform = overall_offset_transform * parent.model_space_transform;
        else
            parent_transform = overall_offset_transform;

        world_space_transform := overall_offset_transform * joint.model_space_transform;
        start := xyz (
            parent_transform._14,
            parent_transform._24,
            parent_transform._34
        );
        end := xyz (
            world_space_transform._14,
            world_space_transform._24,
            world_space_transform._34
        );
        draw_line(start, end, color);
    }
}

// This is maybe the slowest way possible to draw a line!
draw_line :: (start : Vector3, end : Vector3, color : Vector4)
{
    data : [2]Vector3 = ---;
    data[0] = start;
    data[1] = end;

    glBindVertexArray(g_line_vao);
    glBindBuffer(GL_ARRAY_BUFFER, g_line_vbo);
    // Fill the vertex buffer with our two line vertices
    glBufferSubData(GL_ARRAY_BUFFER, 0, size_of(Vector3) * 2, data.data);

    shader := use_basic_shader();
    {
        model := Matrix4_Identity;
        set_mat4(shader, "model", model);
        set_vec4(shader, "color", color);
        glDrawArrays(GL_LINES, 0, 2);
    }
}
