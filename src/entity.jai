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
    animation_name : string;

    bounding_radius : float = 2.0;

    // Non-serialized data.
    mesh : *Mesh;               @NoSerialize

    animation : *Sampled_Animation;  @NoSerialize
    pose : Skeleton_Pose;       @NoSerialize
    animation_time : float = 0; @NoSerialize
    animation_speed_in_fps : float = 60; @NoSerialize
}

Entity_Kind :: enum {
}

Entity_Flags :: enum_flags {
}

update :: (using entity : *Entity, delta_time : float) {
    //update_transforms_with_input(entity, delta_time);

    if entity.animation {
        reset_to_bind_pose(*pose);

        animation_time += delta_time * animation_speed_in_fps;
        sample_animation(
            animation,
            animation_time,
            *pose,
            .LINEAR
        );

        generate_skinning_matrices(*pose);

        assert(pose.skinning_matrices.count <= MAX_JOINTS, "Skinning matrices array cannot have more than % elements for now.");
    }
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

        if entity.animation {
            set_int(shader, "animated", 1);

            // Pass Skinning Matrices
            glBindBuffer(GL_UNIFORM_BUFFER, ubo);
            glBufferSubData(GL_UNIFORM_BUFFER, 0, size_of(Matrix4) * entity.pose.skinning_matrices.count, entity.pose.skinning_matrices.data);
            glBindBuffer(GL_UNIFORM_BUFFER, 0);
        }

        draw_mesh(entity.mesh);

        // Animation Debugging
        if settings.skeleton_debug {
            glDisable(GL_DEPTH_TEST);
            draw_pose(entity.pose, model, pink);
            glEnable(GL_DEPTH_TEST);
        }
    }
    else {
        log_error("Trying to draw entity % which has no mesh!\n", entity.name);
    }

    set_int(shader, "animated", 0);
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
