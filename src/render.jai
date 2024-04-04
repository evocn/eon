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

        glCullFace(GL_FRONT);
        glEnable(GL_CULL_FACE);
        render_scene_to_depth_buffer(game);
        glDisable(GL_CULL_FACE);
        glCullFace(GL_BACK);
    }

    ////////////////////////////////////////////////////////////////////////////////
    // Main Pass
    {
        start_drawing_to_framebuffer(framebuffer);
        {
            if settings.line_mode
                glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

            render_scene(game);

            // Draw Skeleton Pose debug
            {
                // Disable depth mask and testing so we can see the skeleton through other things
                glDisable (GL_DEPTH_TEST);
                    matrix := make_scale_matrix4(Vector3.{1000, 1000, 1000});

                    draw_pose(pose, matrix, white);
                glEnable (GL_DEPTH_TEST);
            }

            if program_state.mode == .EDITOR {
                render_editor_overlays(game);
            }

            glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

            draw_grid();
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

    light_direction := Vector3.{-1, 1, -1};

    {
        // Draw Entities
        shader := use_main_shader();
        defer disable_shaders();

        set_vec3(shader, "light_direction", light_direction);

        entities_drawn := 0;
        for entity : game.entities {
            /*
            if !entity_is_inside_frustum(view_frustum, entity) {
                continue;
            }
            */

            draw_entity(entity, shader);
            entities_drawn += 1;
        }

        screen_print(tprint("Drawn: %", entities_drawn));
    }

    {
        // Draw Plane
        shader := use_main_shader();
        defer disable_shaders();

        set_vec3(shader, "light_direction", light_direction);

        set_int(shader, "animated", 0);
        draw_ground_plane(10, shader);
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

        draw_ground_plane(10, shader);
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

// @TODO: This would be cool, but it sucks balls for some reason due to antialiasing
draw_grid :: () {
    // Draw coordinate axes
    draw_line (.{}, .{x=1}, .{x=1, w=1});
    draw_line (.{}, .{y=1}, .{y=1, w=1});
    draw_line (.{}, .{z=1}, .{z=1, w=1});
    // Draw grid
    for i : -10..10
        draw_line (xyz (xx i, 0, -10), xyz (xx i, 0, 10), .{1.0, 1.0, 1.0, 1});
    for i : -10..10
        draw_line (xyz (-10, 0, xx i), xyz (10, 0, xx i), .{1.0, 1.0, 1.0, 1});
}

draw_pose :: (using pose : Skeleton_Pose, transform : Matrix4, color : Vector4)
{
	for * joints
	{
		parent_transform : Matrix4 = ---;
        parent := it.parent;
		if parent
		    parent_transform = transform * parent.model_space_transform;
		else
			parent_transform = transform;

		world_space_transform := transform * it.model_space_transform;
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
		draw_line (start, end, color);
	}
}

// Used for line rendering
Vertex_Pos_Color :: struct
{
	position : Vector3;
	color : Vector4;
}

draw_line :: inline (start : Vector3, end : Vector3, color : Vector4)
{
	draw_line (start, end, color, color);
}

// This is maybe the slowest way possible to draw a line!
draw_line :: (start : Vector3, end : Vector3, start_color : Vector4, end_color : Vector4)
{
	data : [2]Vertex_Pos_Color = ---;
	data[0].position = start;
	data[0].color    = start_color;
	data[1].position = end;
	data[1].color    = end_color;

	glBindVertexArray (g_line_vao);
	glBindBuffer (GL_ARRAY_BUFFER, g_line_vbo);
	// Fill the vertex buffer with our two line vertices
	glBufferSubData (GL_ARRAY_BUFFER, 0, size_of (Vertex_Pos_Color) * 2, data.data);

    shader := use_basic_shader();
    {
        model := Matrix4_Identity;
        set_mat4(shader, "model", model);
        glDrawArrays(GL_LINES, 0, 2);
    }
}
