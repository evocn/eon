// Author: Alex Hartford
// Program: Everett
// File: Shadow
// Date: August 2023

SHADOW_MAP_SIZE :: 4000;

shadow_map : Shadow_Map;

Shadow_Map :: struct {
    depth_buffer : Depth_Buffer;
    frustum := Orthographic_Frustum.{near = 30.0, far = 30.0, width = 30.0, height = 30.0};
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
    return make_look_at_matrix(Vector3.{2.0, 10.0, 1.0}, Vector3.{0.0, 0.0, 0.0}, Vector3.{0.0, 1.0, 0.0});
}
