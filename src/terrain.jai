// Everett
// Terrain
// Alex Hartford
// April 2024

/*
Goals:
* Triangle Strips
* Nice scaling / stretching
* Terrain editing in-engine
* Tessellation?
*/

Terrain :: struct {
    raw : [..] u8;
    width, height : int;

    using transform : Transform;

    // Rendering
    vao, vbo, ebo : GLuint;
    Vertex :: struct {
        position : Vector3;
        normal   : Vector3;
    }
    vertices : [..] Terrain.Vertex;

    indices  : [..] u32;
    num_strips : int;
    num_vertices_per_strip : int;
}

reset :: (using terrain: *Terrain) {
    array_reset(*raw);
    array_reset(*vertices);
    // etc.
}


load_terrain_from_heightmap_file :: (terrain : *Terrain, filename : string) -> bool {
    reset(terrain);

    terrain.y = 15;

	full_path := tprint("%/%", heightmaps_path, filename);

    // Load Data from file and save to the terrain.
    size, width, height, dim : s32;
    {
        desired_components :: 1;
        data := stbi_load(temp_c_string(full_path), *width, *height, *dim, desired_components);

        if !data {
            log_error("Failed to load heightmap at %\n", filename);
            return false;
        }

        size = width * height;

        // Save Raw data to the Terrain.
        {
            terrain.width  = width;
            terrain.height = height;

            array_resize(*terrain.raw, size, initialize = false);

            memcpy(terrain.raw.data, data, size * size_of(u8));
        }

        stbi_image_free(data);
    }


    // Generate geometry for rendering
    {
        // Vertices
        {
            array_resize(*terrain.vertices, size, initialize = false);

            for point, index : terrain.raw {
                col := index % width;
                row := index / width;

                offset := Vector3.{xx (-width / 2), -20, xx (-height / 2)};

                position : Vector3 = ---;
                {
                    position = .{xx col, xx (point / 10), xx row};
                    //position = .{xx col, 0, xx row};

                    position += offset;
                }

                normal : Vector3 = ---;
                {
                    //normal = .{0, 1, 0};

                    r, l, b, t : float;
                    if col == width-1   then r = 1; else r = xx terrain.raw[index + 1];
                    if col == 0         then l = 1; else l = xx terrain.raw[index - 1];
                    if row == height-1  then b = 1; else b = xx terrain.raw[index + width];
                    if row == 0         then t = 1; else t = xx terrain.raw[index - width];
                    normal = .{2 * (r - l), -4, 2 * (b - t)};
                    normal = -1 * normalize(normal);
                }

                terrain.vertices[index] = .{
                    position,
                    normal,
                };
            }
        }

        // Indices
        {
            num_strips := height - 1;

            total_num_indices := 2 * num_strips * width;
            array_resize(*terrain.indices, total_num_indices, initialize = false);

            index : int;
            for strip : 0 .. num_strips - 1 {
                for col : 0 .. width - 1 {
                    terrain.indices[index] = xx (col + width * (strip + 0));
                    index += 1;
                    terrain.indices[index] = xx (col + width * (strip + 1));
                    index += 1;
                }
            }

            // Set terrain variables for indexed rendering
            terrain.num_strips = num_strips;
            terrain.num_vertices_per_strip = width * 2;
        }
    }

    init_terrain_rendering_objects(terrain);

    return true;
}


init_terrain_rendering_objects :: (using terrain: *Terrain) {
    glGenVertexArrays(1, *vao);
    glGenBuffers(1, *vbo);
    glGenBuffers(1, *ebo);

    glBindVertexArray(vao);

    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, size_of(Terrain.Vertex) * vertices.count, vertices.data, GL_STATIC_DRAW);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, size_of(u32) * indices.count, indices.data, GL_STATIC_DRAW);

    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, size_of(Terrain.Vertex), cast(*void)0);

    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, size_of(Terrain.Vertex), cast(*void)(size_of(Vector3)));
}

draw_terrain :: (using terrain: Terrain, shader : Shader)
{
    model := model_matrix(terrain.transform);
    set_mat4(shader, "model", model);

    set_vec4(shader, "color_override", blue);

    {
        glBindVertexArray(vao);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);

        for strip_index : 0 .. terrain.num_strips - 1 {
            pointer := cast(*void)(size_of(u32) * num_vertices_per_strip * strip_index);
            glDrawElements(GL_TRIANGLE_STRIP, xx num_vertices_per_strip, GL_UNSIGNED_INT, pointer);
        }
    }
}
