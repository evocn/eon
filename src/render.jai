// Everett
// Render
// Alex Hartford
// June 2023

shadow_debug : bool;

render :: (entities : [..] *Entity) {

    {
        // Shadow pass, drawing to the depth buffer.
        start_drawing_to_depth_buffer(shadow_map.depth_buffer);

        glCullFace(GL_FRONT);
        render_scene_to_depth_buffer(entities);
        glCullFace(GL_BACK);

        if shadow_debug {
            draw_buffer_to_the_screen(shadow_map.depth_buffer.buffer);
            return;
        }
    }

    {
        // Render Scene to the framebuffer.
        start_drawing_to_framebuffer(framebuffer);

        render_scene(entities);

        draw_buffer_to_the_screen(framebuffer.color_buffer);
    }

    {
        glDisable(GL_DEPTH_TEST);
        defer glEnable(GL_DEPTH_TEST);

        // Draw Text
        shader := use_text_shader();
        defer disable_shaders();

        font, found := table_find(*fonts, "Header");
        for debug.lines {
            draw_text(shader, font, it, 10, window_height - 10 - cast(float)(it_index + 1) * font.height, 1.0);
        }
    }

    check_gl_error();
}

render_scene :: (entities : [..] *Entity) {
    view_frustum := calculate_view_frustum(camera.projection, camera.view);

    {
        // Draw Entities
        shader := use_main_shader();
        defer disable_shaders();

        entities_drawn := 0;
        for entities {
            if !point_is_inside_frustum(view_frustum, it.position) {
                continue;
            }

            draw_entity(it, shader);
            entities_drawn += 1;
        }

        screen_print(tprint("Drawn: %\n", entities_drawn));
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

//
//

//GL_BIG_DATA_UNIFORM_BINDING :: 0;
//g_big_data_ubo : GLuint;

draw_skinned_mesh :: (using mesh : Skinned_Mesh, skinning_matrices : []Matrix4)
{
	assert(skinning_matrices.count <= MAX_JOINTS, "Skinning matrices array cannot have more than % elements for now.");

	// Fill the uniform buffer with the skinning data
	glBindVertexArray(vao);
    /*
	glBindBuffer(GL_UNIFORM_BUFFER, g_big_data_ubo);
	glBufferSubData(GL_UNIFORM_BUFFER, 0, size_of(Matrix4) * skinning_matrices.count, skinning_matrices.data);
	glBindBuffer(GL_UNIFORM_BUFFER, 0);
    */

	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);

	glDrawElements(GL_TRIANGLES, cast(u32)indices.count, GL_UNSIGNED_INT, null);
}
