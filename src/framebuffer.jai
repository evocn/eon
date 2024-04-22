// Everett
// Framebuffer
// Alex Hartford
// August 2023

framebuffer : Framebuffer;

Framebuffer :: struct {
    width, height : u32 = default_framebuffer_width, default_framebuffer_height;
    fbo, color_buffer, depth_buffer : GLuint;
}

////////////////////////////////////////////////////////////////////////////////

draw_framebuffer_to_screen_with_post_processing :: (using framebuffer : Framebuffer) {
    start_drawing_to_screen();
    glViewport(0, 0, xx window_width, xx window_height);

    glDisable(GL_DEPTH_TEST);
    defer glEnable(GL_DEPTH_TEST);

    shader := render_context.post_processing_shader;
    {
        use_shader(shader);
        defer disable_shaders();

        set_vec3(shader, "camera_position", program_state.camera.position);

        {
            set_texture(shader, "color_texture", 0);
            glActiveTexture(GL_TEXTURE0 + 0);
            glBindTexture(GL_TEXTURE_2D, color_buffer);
        }

        {
            set_texture(shader, "depth_texture", 1);
            glActiveTexture(GL_TEXTURE0 + 1);
            glBindTexture(GL_TEXTURE_2D, depth_buffer);
        }

        draw_quad();
    }
}

////////////////////////////////////////////////////////////////////////////////

start_drawing_to_framebuffer :: (using framebuffer : Framebuffer) {
    glBindFramebuffer(GL_FRAMEBUFFER, fbo);
    glViewport(0, 0, width, height);
    glClearColor(0.0, 0.0, 0.1, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

start_drawing_to_screen :: () {
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

////////////////////////////////////////////////////////////////////////////////

draw_buffer_to_the_screen :: (buffer : GLuint, x: s32, y: s32, width: u32, height: u32) {
    start_drawing_to_screen();
    glViewport(x, y, width, height);

    glDisable(GL_DEPTH_TEST);
    defer glEnable(GL_DEPTH_TEST);

    shader := render_context.screen_shader;
    {
        use_shader(shader);
        defer disable_shaders();

        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, buffer);

        draw_quad();
    }
}

////////////////////////////////////////////////////////////////////////////////

init_rendering_objects :: (using framebuffer : *Framebuffer) {
    // framebuffer configuration
    glGenFramebuffers(1, *fbo);
    glBindFramebuffer(GL_FRAMEBUFFER, fbo);

    // create a color attachment textures
    {
        glGenTextures(1, *color_buffer);
        glBindTexture(GL_TEXTURE_2D, color_buffer);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, null);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);

        borderColor := float.[1.0, 1.0, 1.0, 1.0];
        glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, borderColor.data);

        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, color_buffer, 0);
    }

    // create a depth attachment texture
    {
        glGenTextures(1, *depth_buffer);
        glBindTexture(GL_TEXTURE_2D, depth_buffer);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT32, width, height, 0, GL_DEPTH_COMPONENT, GL_FLOAT, null);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);

        borderColor := float.[1.0, 1.0, 1.0, 1.0];
        glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, borderColor.data);

        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, depth_buffer, 0);
    }

    // Verify that things look good
    assert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}
