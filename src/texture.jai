// Everett
// Texture
// Alex Hartford
// June 2023

next_bind_id : GLuint = 0;

bind_texture :: (texture_id : GLuint) -> GLuint {
    bind_id : GLuint = GL_TEXTURE0 + next_bind_id;
    glActiveTexture(bind_id);
    next_bind_id += 1;
    glBindTexture(GL_TEXTURE_2D, texture_id);

    return next_bind_id - 1;
}

clear_texture :: (using texture : Texture) {
    glDeleteTextures(1, *id);
}

Texture :: struct {
    id : u32;
    width, height, dim : u32;
    format : GLenum;
}

//
//

textures_path :: "assets/textures";

load_texture_from_memory :: (memory : string) -> Texture {
    texture : Texture;

    data := stbi_load_from_memory(temp_c_string(memory), xx memory.count, xx *texture.width, xx *texture.height, xx *texture.dim, 4);

    if !data {
        log_error("Failed to load texture from data.\n");
        return .{};
    }

    set_up_texture(*texture, data);

    return texture;
}

load_texture_from_file :: (filename : string) -> Texture {
    texture : Texture;

    cstr_path := temp_c_string(tprint("%/%", textures_path, filename));
    data := stbi_load(cstr_path, xx *texture.width, xx *texture.height, xx *texture.dim, 4);

    if !data {
        log_error("Failed to load texture %.\n", filename);
        return .{};
    }

    set_up_texture(*texture, data);

    stbi_image_free(data);

    return texture;
}

set_up_texture :: (using texture : *Texture, data : *u8) {
    fmt : GLenum;
    if dim == 1 then fmt = GL_RED;
    else if dim == 3 || dim == 4 then fmt = GL_RGBA;
    else {
        log_error("Unknown image format: \"%\".\n", dim);
        return;
    }

    glGenTextures(1, *id);
    glBindTexture(GL_TEXTURE_2D, id);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, xx ifx fmt == GL_RGBA then GL_CLAMP_TO_EDGE else GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, xx ifx fmt == GL_RGBA then GL_CLAMP_TO_EDGE else GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
 
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, xx width, xx height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    glGenerateMipmap(GL_TEXTURE_2D);

    glBindTexture(GL_TEXTURE_2D, 0);
}

#scope_file

make_image :: (width : u32, height : u32, format : GLenum) -> Texture {
    return make_texture(width, height, format, 0, 0, .[
            GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE,
            GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE, 
            GL_TEXTURE_MIN_FILTER, GL_NEAREST,
            GL_TEXTURE_MAG_FILTER, GL_NEAREST
         ]);
}

make_texture :: (width : u32, height : u32, format : GLenum, channels : GLenum, type : GLenum, params : []GLenum, src : *u8 = null, mipmap := true) -> Texture {
    result := Texture.{width = width, height = height, format = format};

    glGenTextures(1, *result.id);
    glBindTexture(GL_TEXTURE_2D, result.id);
    {
        for i : 0..params.count/2 - 1 {
            glTexParameteri(GL_TEXTURE_2D, xx params[i * 2], xx params[i * 2 + 1]);
        }

        glTexImage2D(GL_TEXTURE_2D, 0, xx format, xx width, xx height, 0, channels, type, src);
        if mipmap glGenerateMipmap(GL_TEXTURE_2D);
    }
    glBindTexture(GL_TEXTURE_2D, 0);

    return result;
}
