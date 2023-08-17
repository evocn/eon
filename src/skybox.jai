// Everett
// Skybox
// Alex Hartford
// June 2023

// @NOTE: Most of the load time for the engine right now is loading big textures.
// For that reason, we're running with super low-res textures here. We probably want to do more research
// Into how to do big textures in the first place. My guess: We don't.

skybox_path :: "assets/skyboxes";

Skybox :: struct {
    name : string;
    id: GLuint;
}

draw_skybox :: (shader : Shader) {
    glDepthFunc(GL_LEQUAL);
    glBindTexture(GL_TEXTURE_CUBE_MAP, render_context.skybox.id);
    draw_cube();
    glDepthFunc(GL_LESS);
}

// Returns the ID of the cubemap texture.
load_cubemap_textures :: (using skybox : *Skybox, directory_name : string)
{
    glGenTextures(1, *id);
    glBindTexture(GL_TEXTURE_CUBE_MAP, id);

    faces := string.["right", "left", "top", "bottom", "front", "back"];

    width, height, nrComponents : s32;
    min, max : u32 = 0, 5;
    for i : min..max {
        filename := tprint("%/%.png", directory_name, faces[i]);
        full_path_c_string := temp_c_string(tprint("%/%", skybox_path, filename));
        data := stbi_load(full_path_c_string, *width, *height, *nrComponents, 0);
        defer stbi_image_free(data);

        if !data {
            log_error("STB Image: Cubemap loading failed for file \"%\".\n", filename);
            return;
        }
        format : s32 = GL_RGB;
        if nrComponents == 1      format = GL_RED;
        else if nrComponents == 3 format = GL_RGB;
        else if nrComponents == 4 format = GL_RGBA;

        glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X + i,
                     0, format, xx width, xx height, 
                     0, xx format, GL_UNSIGNED_BYTE, data);
    }

    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);  
}
