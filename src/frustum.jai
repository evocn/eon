// Author: Alex Hartford
// Program: Everett
// File: Frustum
// Date: August 2023

Orthographic_Frustum :: struct {
    near    : float;
    far     : float;
    width   : float;
    height  : float;
}

get_projection_matrix :: (using frustum: Orthographic_Frustum) -> Matrix4 {
    return orthographic_projection_matrix(
        left   = -width,  right = width,
        bottom = -height, top   = height,
        near   = -near,   far   = far
    );
}

//
//

Frustum :: struct {
    planes : [6] Plane3;
}

// @TODO: Make a better spatial query, something like a bounding sphere test on its furthest extent to make sure that it's completely out.
point_is_inside_frustum :: (frustum : Frustum, point: Vector3) -> bool {
    for frustum.planes {
        distance := plane_dot(it, point);
        if distance < 0 {
            return false;
        }
    }

    return true;
}

calculate_view_frustum :: (projection : Matrix4, view : Matrix4) -> Frustum {
    using frustum : Frustum;
    comp := (transpose(projection * view)).coef;

    // Left
    planes[0].a = comp[0][3] + comp[0][0];
    planes[0].b = comp[1][3] + comp[1][0];
    planes[0].c = comp[2][3] + comp[2][0];
    planes[0].d = comp[3][3] + comp[3][0];
    planes[0] = normalize(planes[0]);

    // Right
    planes[1].a = comp[0][3] - comp[0][0]; 
    planes[1].b = comp[1][3] - comp[1][0]; 
    planes[1].c = comp[2][3] - comp[2][0]; 
    planes[1].d = comp[3][3] - comp[3][0];
    planes[1] = normalize(planes[1]);

    // Bottom
    planes[2].a = comp[0][3] + comp[0][1]; 
    planes[2].b = comp[1][3] + comp[1][1]; 
    planes[2].c = comp[2][3] + comp[2][1]; 
    planes[2].d = comp[3][3] + comp[3][1];
    planes[2] = normalize(planes[2]);

    // Top
    planes[3].a = comp[0][3] - comp[0][1]; 
    planes[3].b = comp[1][3] - comp[1][1]; 
    planes[3].c = comp[2][3] - comp[2][1]; 
    planes[3].d = comp[3][3] - comp[3][1];
    planes[3] = normalize(planes[3]);

    // Near
    planes[4].a = comp[0][3];
    planes[4].b = comp[1][3];
    planes[4].c = comp[2][3];
    planes[4].d = comp[3][3];
    planes[4] = normalize(planes[4]);

    // Far
    planes[5].a = comp[0][3] - comp[0][2];
    planes[5].b = comp[1][3] - comp[1][2];
    planes[5].c = comp[2][3] - comp[2][2];
    planes[5].d = comp[3][3] - comp[3][2];
    planes[5] = normalize(planes[5]);
    
    return frustum;
}
