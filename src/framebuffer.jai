// Everett
// Framebuffer
// Alex Hartford
// August 2023

framebuffer : Framebuffer;

Framebuffer :: struct {
    width, height : u32 = default_framebuffer_width, default_framebuffer_height;
    fbo, color_buffer, depth_buffer, rbo : GLuint;
}

//
//

start_drawing_to_framebuffer :: (using framebuffer : Framebuffer) {
    glBindFramebuffer(GL_FRAMEBUFFER, fbo);
    glViewport(0, 0, width, height);
    glClearColor(1.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

start_drawing_to_screen :: () {
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

draw_buffer_to_the_screen :: (buffer : GLuint, x: s32, y: s32, width: u32, height: u32) {
    start_drawing_to_screen();
    glViewport(x, y, width, height);

    glDisable(GL_DEPTH_TEST);
    defer glEnable(GL_DEPTH_TEST);

    shader := render_context.screen_shader;
    use_shader(shader);
    defer disable_shaders();

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, buffer);

    draw_quad();
}

//
//

init_rendering_objects :: (using framebuffer : *Framebuffer) {
    // framebuffer configuration
    glGenFramebuffers(1, *fbo);
    glBindFramebuffer(GL_FRAMEBUFFER, fbo);

    // create a color attachment textures
    glGenTextures(1, *color_buffer);
    glBindTexture(GL_TEXTURE_2D, color_buffer);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, null);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, color_buffer, 0);

    // create a depth attachment texture
    glGenTextures(1, *depth_buffer);
    glBindTexture(GL_TEXTURE_2D, depth_buffer);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB32F, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, null);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT1, GL_TEXTURE_2D, depth_buffer, 0);

    // create a renderbuffer object for depth and stencil attachment
    glGenRenderbuffers(1, *rbo);
    glBindRenderbuffer(GL_RENDERBUFFER, rbo);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, width, height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, rbo);

    assert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}
