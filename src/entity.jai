// Eon
// Entity
// Alex Hartford
// June 2023

Entity :: struct {
    kind  : Entity_Kind;
    serial: u64;
    name  : string;
    flags : Entity_Flags;

    using transform : Transform;

    mesh_name : string;
    animation_name : string;

    // Non-serialized data.
    bounding_box : Box;         @NoSerialize
    mesh : *Mesh;               @NoSerialize

    using character_controller : Character_Controller; @NoSerialize
    using animation_controller : Animation_Controller; @NoSerialize
}

Entity_Kind :: enum {
}

Entity_Flags :: enum_flags {
}

update :: (using entity : *Entity, delta_time : float) {
    //update_transforms_with_input(entity, delta_time);

    // Recalculate Bounding Box
    {
        bounding_box = calculate_bounding_box(entity);
    }

    // Update Animation
    if entity.animation_name {
        update(*entity.animation_controller, delta_time);
    }
}

////////////////////////////////////////////////////////////////////////////////

calculate_bounding_box :: (using entity : Entity) -> Box {
    low_extent, high_extent := find_extents(mesh, transform);
    return Box.{low_extent, high_extent};
}

////////////////////////////////////////////////////////////////////////////////

draw_entity :: (entity : Entity, shader : Shader) {
    if !entity.mesh {
        log_error("Heads up - you're calling draw on entity % which has no mesh!\n", entity.name);
    }

    bind_id := bind_texture(entity.mesh.texture.id);
    set_int(shader, "diffuse_texture", bind_id);

    set_vec4(shader, "color_override", red);

    model := model_matrix(entity.transform);
    set_mat4(shader, "model", model);

    if entity.animation_name {
        set_int(shader, "animated", 1);

        // Pass Skinning Matrices
        glBindBuffer(GL_UNIFORM_BUFFER, ubo);
        glBufferSubData(GL_UNIFORM_BUFFER, 0, size_of(Matrix4) * entity.pose.skinning_matrices.count, entity.pose.skinning_matrices.data);
        glBindBuffer(GL_UNIFORM_BUFFER, 0);
    }

    draw_mesh(entity.mesh);

    // Cleanup
    {
        set_int(shader, "animated", 0);
    }
}

// This is necessary since entities tend to have their "Position" be at the feet of the thing.
// So this function gets you the real center of an object with regard to its mesh, etc.
get_center_of_bounding_box :: (using entity : Entity) -> Vector3 {
    box_center_relative_to_position := (bounding_box.max + bounding_box.min) / 2;

    // Only need the y.
    box_center_relative_to_position.x = 0;
    box_center_relative_to_position.z = 0;

    return position + box_center_relative_to_position;
}

draw_bounding_box :: (using entity : Entity, shader : Shader) {
    box := *entity.bounding_box;

    scale_vector := (box.max - box.min) / 2.0;
    box_center   := (box.max + box.min) / 2.0;

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

find_entity_animation :: (using entity: *Entity) {
    found_anim : bool;
    animation, found_anim = table_find(*animation_catalogue, animation_name);
    if !found_anim {
        log_error("Entity's anim was not found: %.", animation_name);
        animation = null;
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
