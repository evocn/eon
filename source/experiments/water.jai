// Eon
// Water
// Alex Hartford
// April 2024

Water :: struct {
    reflection : Framebuffer;
    //refraction : Framebuffer;

    using transform : Transform;
}

draw :: (using water : Water, shader : Shader) {
    model := model_matrix(water.transform);

    set_mat4(shader, "model", model);

    // Reflection
    {
        set_texture(shader, "reflection_texture", 0);
        glActiveTexture(GL_TEXTURE0 + 0);
        glBindTexture(GL_TEXTURE_2D, reflection.color_buffer);
    }

    draw_quad();
}

init_rendering_objects :: (using water : *Water) {
    init_rendering_objects(*reflection);
    //init_rendering_objects(*refraction);
}
