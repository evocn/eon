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

draw_entity :: (using entity : Entity, shader : Shader) {
    if mesh {
        bind_id := bind_texture(mesh.texture.id);
        set_int(shader, "diffuse_texture", bind_id);

        set_vec4(shader, "color_override", green);

        scale_mat   := make_scale_matrix4(Vector3.{scale, scale, scale});
        rotation    := rotation_matrix(Matrix4, orientation);
        translation := make_translation_matrix4(position);
        model := translation * rotation * scale_mat;
        set_mat4(shader, "model", model);

        //if mesh_name == "test" {
        //if mesh_name == "bird" {
        if false {
            bind_skinning_matrices(pose.skinning_matrices, shader);
            set_int(shader, "animated", 1);
        }
        else {
            bind_skinning_matrices(.[], shader);
            set_int(shader, "animated", 0);
        }

        draw_mesh(mesh);
    }
    else {
        log_error("Trying to draw entity % which has no mesh!\n", name);
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
