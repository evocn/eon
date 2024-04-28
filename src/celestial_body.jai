// Eon
// Celestial Body (Sun, Moon, etc.)
// Alex Hartford
// April 2024

Celestial_Body :: struct {
    using transform : Transform;
}

draw :: (celestial_body : Celestial_Body, shader : Shader) {
    model := model_matrix(celestial_body.transform);

    set_mat4(shader, "model", model);
    set_vec4(shader, "color", white);

    draw_sphere();
}

get_light_direction :: (body : Celestial_Body) -> Vector3 {
    return normalize(body.position);
}

