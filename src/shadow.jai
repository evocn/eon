// Everett
// Shadow
// Alex Hartford
// August 2023

SHADOW_MAP_SIZE :: 8000;

shadow_map : Shadow_Map;

Shadow_Map :: struct {
    depth_buffer : Depth_Buffer;
    frustum := Orthographic_Frustum.{near = 50.0, far = 50.0, width = 50.0, height = 50.0};
    light_position := Vector3.{1.0, 1.0, 1.0};
}

//
//

init_rendering_objects :: (using shadow_map : *Shadow_Map) {
    depth_buffer.width  = SHADOW_MAP_SIZE;
    depth_buffer.height = SHADOW_MAP_SIZE;
    init_rendering_objects(*depth_buffer);
}

get_shadow_map_projection_matrix :: (using shadow_map : Shadow_Map) -> Matrix4 {
    return get_projection_matrix(frustum);
}

get_shadow_map_view_matrix :: (using shadow_map : Shadow_Map) -> Matrix4 {
    return make_look_at_matrix(light_position, Vector3.{0.0, 0.0, 0.0}, Vector3.{0.0, 1.0, 0.0});
}
