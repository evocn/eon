// Everett
// Entity
// Alex Hartford
// June 2023

Entity :: struct {
    kind  : Entity_Kind;
    serial: u64;
    name  : string;
    flags : Entity_Flags;

    using transform : Transform;
    using controller: Character_Controller; @NoSerialize

    mesh_name : string;

    bounding_radius : float = 2.0;

    // Non-serialized data.
    mesh : *Mesh; @NoSerialize
}

Entity_Kind :: enum {
}

Entity_Flags :: enum_flags {
}

update :: (using entity : *Entity, delta_time : float) {
    //update_transforms_with_input(entity, delta_time);
}

////////////////////////////////////////////////////////////////////////////////

calculate_bounding_box :: (using entity : Entity) -> Box {
    low_extent, high_extent := find_extents(mesh, transform);
    return Box.{low_extent, high_extent};
}

////////////////////////////////////////////////////////////////////////////////

draw_entity :: (entity : Entity, shader : Shader) {
    if entity.mesh {
        bind_id := bind_texture(entity.mesh.texture.id);
        set_int(shader, "diffuse_texture", bind_id);

        set_vec4(shader, "color_override", blue);

        scale_mat   := make_scale_matrix4(Vector3.{entity.scale, entity.scale, entity.scale});
        rotation    := rotation_matrix(Matrix4, entity.orientation);
        translation := make_translation_matrix4(entity.position);
        model := translation * rotation * scale_mat;
        set_mat4(shader, "model", model);

        if false {
            assert (pose.skinning_matrices.count <= MAX_JOINTS, "Skinning matrices array cannot have more than % elements for now.");

            // @TODO: This is currently copying over all the matrices because of the stupid fucking transposition thing.
            // We should probably just transpose when we generate these, or whatever.
            new_skinning_matrices := NewArray(pose.skinning_matrices.count, Matrix4);
            for pose.skinning_matrices {
                new_skinning_matrices[it_index] = transpose(it);
                //new_skinning_matrices[it_index] = it;
            }

            // Fill the uniform buffer with the skinning data
            glBindBuffer(GL_UNIFORM_BUFFER, ubo);
            glBufferSubData(GL_UNIFORM_BUFFER, 0, size_of(Matrix4) * new_skinning_matrices.count, new_skinning_matrices.data);
            glBindBuffer(GL_UNIFORM_BUFFER, 0);

            set_int(shader, "animated", 1);
        }
        else {
            set_int(shader, "animated", 0);
        }

        draw_mesh(entity.mesh);
    }
    else {
        log_error("Trying to draw entity % which has no mesh!\n", entity.name);
    }
}

draw_bounding_box :: (using entity : Entity, shader : Shader) {
    box := calculate_bounding_box(entity);

    scale_vector := Vector3.{box.max.x - box.min.x, box.max.y - box.min.y, box.max.z - box.min.z} / 2.0;
    box_center   := Vector3.{box.max.x + box.min.x, box.max.y + box.min.y, box.max.z + box.min.z} / 2.0;

    scale_mat    := make_scale_matrix4(scale_vector);
    rotation     := Matrix4_Identity;
    translation  := make_translation_matrix4(box_center);
    model := translation * rotation * scale_mat;
    set_mat4(shader, "model", model);

    draw_cube();
}

////////////////////////////////////////////////////////////////////////////////

find_entity_mesh :: (using entity: *Entity) {
    found_mesh : bool;
    mesh, found_mesh = table_find(*mesh_catalogue, mesh_name);
    if !found_mesh {
        log_error("Entity's mesh was not found: %.", mesh_name);
        mesh = null;
    }
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
