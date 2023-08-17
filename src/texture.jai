// Everett
// Texture
// Alex Hartford
// June 2023

bind :: (texture : Texture, bind_id : u32) {
	bind_texture(texture.id, bind_id);
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

load_texture :: (filename : string) -> Texture {
	using result : Texture;

	cstr_path := temp_c_string(tprint("%/%", textures_path, filename));
	data := stbi_load(cstr_path, xx *width, xx *height, xx *dim, 4); defer stbi_image_free(data);

	if(!data) {
		log_error("Failed to load texture %.\n", filename);
        assert(false);
	}
	fmt : GLenum;
	if dim == 1 then fmt = GL_RED;
	else if dim == 3 || dim == 4 then fmt = GL_RGBA;
	else {
        log_error("Unknown image format: \"%\".\n", dim);
        return .{};
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

	return result;
}

#scope_file

bind_texture :: (texture_id : u32, bind_id : u32) {
	glActiveTexture(GL_TEXTURE0 + bind_id);
	glBindTexture(GL_TEXTURE_2D, texture_id);
}

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
		for i : 0..params.count/2 - 1 {
			glTexParameteri(GL_TEXTURE_2D, xx params[i * 2], xx params[i * 2 + 1]);
		}

        glTexImage2D(GL_TEXTURE_2D, 0, xx format, xx width, xx height, 0, channels, type, src);
        if mipmap glGenerateMipmap(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, 0);

	return result;
}
