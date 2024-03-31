// Everett
// Font
// Alex Hartford
// June 2023

fonts_path :: "assets/fonts";

Font :: struct {
    characters : Table(u8, Character_Glyph);
    height : int;
    vao, vbo : GLuint;
}

make_font :: (filename: string, size: u32) -> Font {
    return initialize_font(filename, size);
}

draw_text :: (shader: Shader, font: Font, text: string, 
              x: float, y: float, scale := 1.0, color := white)
{
    set_vec4(shader, "color", color);
    render_text(font, text, x, y, scale);
}

////////////////////////////////////////////////////////////////////////////////

#scope_file

ft : *FT_Library;

initialize_freetype :: () {
    if FT_Init_FreeType(*ft) {
        log_error("Could not initialize the Freetype Library.\n");
        assert(false);
    }
}

render_text :: (font : Font, text : string, x : float, y : float, scale : float)
{
    glActiveTexture(GL_TEXTURE0);
    glBindVertexArray(font.vao);

    for cast([] u8)text
    {
        glyph, found := table_find(*font.characters, it);
        assert(found);

        xpos := x + glyph.bearing.x * scale;
        ypos := y - (glyph.size.y - glyph.bearing.y) * scale;

        w := glyph.size.x * scale;
        h := glyph.size.y * scale;

        // update VBO for each character
        vertices : [6][4] float;

        tmp : [4] float;
        tmp[0] = xpos;
        tmp[1] = ypos + h;
        tmp[2] = 0.0;
        tmp[3] = 0.0;
        vertices[0] = tmp;

        tmp[0] = xpos;
        tmp[1] = ypos;
        tmp[2] = 0.0;
        tmp[3] = 1.0;
        vertices[1] = tmp;

        tmp[0] = xpos + w;
        tmp[1] = ypos;
        tmp[2] = 1.0;
        tmp[3] = 1.0;
        vertices[2] = tmp;

        tmp[0] = xpos;
        tmp[1] = ypos + h;
        tmp[2] = 0.0;
        tmp[3] = 0.0;
        vertices[3] = tmp;

        tmp[0] = xpos + w;
        tmp[1] = ypos;
        tmp[2] = 1.0;
        tmp[3] = 1.0;
        vertices[4] = tmp;

        tmp[0] = xpos + w;
        tmp[1] = ypos + h;
        tmp[2] = 1.0;
        tmp[3] = 0.0;
        vertices[5] = tmp;

        // render glyph texture over quad
        glBindTexture(GL_TEXTURE_2D, glyph.id);
        // update content of VBO memory
        glBindBuffer(GL_ARRAY_BUFFER, font.vbo);
        glBufferSubData(GL_ARRAY_BUFFER, 0, 6 * 4 * size_of(float), vertices.data); // be sure to use glBufferSubData and not glBufferData

        glBindBuffer(GL_ARRAY_BUFFER, 0);
        // render quad
        glDrawArrays(GL_TRIANGLES, 0, 6);
        // advance cursors for next glyph (note that advance is number of 1/64 pixels)
        x += (glyph.advance >> 6) * scale; // (2^6 = 64)
    }
    glBindVertexArray(0);
    glBindTexture(GL_TEXTURE_2D, 0);
}

//
//

Character_Glyph :: struct {
    id : GLuint;
    size    : Vector2; // Size of glyph
    bearing : Vector2; // Offset from baseline to left/top of glyph
    advance : u64;     // Offset to advance to next glyph
};

initialize_font :: (filename : string, size : u32) -> Font {
    a: Allocator;
    a.proc = flat_pool_allocator_proc;
    a.data = *forever_pool;

    if !ft {
        initialize_freetype();
    }

    face : FT_Face;
    full_path := temp_c_string(tprint("%/%", fonts_path, filename));
    if FT_New_Face(ft, full_path, 0, *face) {
        log_error("Freetype failed to load font \"%\"\n", filename);
        assert(false);
    }

    //                       w  h
    FT_Set_Pixel_Sizes(face, 0, size);

    glPixelStorei(GL_UNPACK_ALIGNMENT, 1); // disable byte-alignment restriction

    font : Font;
    font.height = size;

    font.characters.allocator=a;

    zero : u32;
    top : u32 = 127;
    for c : zero..top {
        // load character glyph 
        if FT_Load_Char(face, c, FT_LOAD_RENDER) {
            log_error("Freetype failed to load Glyph.\n");
            assert(false);
        }

        // generate texture
        id : GLuint;
        glGenTextures(1, *id);
        glBindTexture(GL_TEXTURE_2D, id);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RED,
            xx face.glyph.bitmap.width, xx face.glyph.bitmap.rows,
            0, GL_RED, GL_UNSIGNED_BYTE, face.glyph.bitmap.buffer);
        // set texture options
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        // now store character for later use
        glyph := Character_Glyph.{
            id,
            Vector2.{xx face.glyph.bitmap.width, xx face.glyph.bitmap.rows},
            Vector2.{xx face.glyph.bitmap_left, xx face.glyph.bitmap_top},
            xx face.glyph.advance.x
        };
        table_add(*font.characters, cast(u8)c, glyph);
    }

    FT_Done_Face(face);
    FT_Done_FreeType(ft);

    init_font_rendering_objects(*font);

    return font;
}

init_font_rendering_objects :: (using font : *Font) {
    glGenVertexArrays(1, *vao);
    glGenBuffers(1, *vbo);
    glBindVertexArray(vao);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, size_of(float) * 6 * 4, null, GL_DYNAMIC_DRAW);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 4 * size_of(float), cast(*void)0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
}

