// Everett
// Entity
// Alex Hartford
// June 2023

Entity :: struct {
    kind : Entity_Kind;
    serial : u64;
    name : string;

    using position : Vector3;
    orientation    : Quaternion;
    scale := 1.0;

    flags : Entity_Flags;

    mesh_name : string;

    mesh : *Skinned_Mesh;           @NoSerialize
}

Entity_Kind :: enum {
    BOX;
}

Entity_Flags :: enum_flags {
    HIDDEN;
    FROZEN;
}

// Generates a new spot in memory, avoids slicing off derived bits, etc.
copy_entity :: (using copy_from: *Entity) -> *Entity {
    copy_to := New(Entity);
    if kind == {
        case;
            memcpy(copy_to, copy_from, size_of(Entity));
            return copy_to;
    }
}

//
//
//

draw_entity :: (using entity : *Entity, shader : Shader) {
    if mesh {
        scale_mat   := make_scale_matrix4(Vector3.{scale, scale, scale});
        rotation    := rotation_matrix(Matrix4, orientation);
        translation := make_translation_matrix4(position);
        model := translation * rotation * scale_mat;
        set_mat4(shader, "model", model);

        draw_skinned_mesh(mesh, .[]);
    }
    else {
        log_error("Trying to draw entity % which has no mesh!\n", name);
    }
}

draw_selected_entity :: (using entity : *Entity, shader : Shader) {
    oscillating := sin(cast(float32)get_time());
    set_float(shader, "highlight", oscillating);
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

    draw_skinned_mesh(mesh, .[]);

    // Set the Line Mode back to what it was before.
    if settings.line_mode
        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    else
        glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

    set_float(shader, "highlight", 0.0);
}
