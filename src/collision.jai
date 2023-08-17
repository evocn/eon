// Everett
// Collision Detection and Resolution
// Alex Hartford
// June 2023

Ray :: struct {
    origin : Vector3;
    direction : Vector3;
}

generate_mouse_ray :: (x : float, y : float) -> Ray {
    mouse_position_in_clip_space : Vector4;
    mouse_position_in_clip_space.x = 2 * x / (window_width) - 1;
    mouse_position_in_clip_space.y = 1 - 2 * y / (window_height);
    mouse_position_in_clip_space.z = -1.0;
    mouse_position_in_clip_space.w = 1;

    mouse_position_in_world_space := inverse(camera.projection * camera.view) * mouse_position_in_clip_space;

    ray : Ray;
    ray.origin = camera.position;
    ray.direction = normalize(mouse_position_in_world_space.xyz - ray.origin);

    return ray;
}

make_line_from_ray :: (using ray : Ray) -> Line {
    line : Line;
    array_add(*line.points, origin);
    array_add(*line.points, origin + direction * 30);
    init_line_rendering_objects(*line);
    return line;
}

//
//

Box :: struct {
    min : Vector3;
    max := Vector3.{1, 1, 1};
}

intersection :: (ray : Ray, box : Box) -> bool, t: float {
    dirfrac : Vector3;
    dirfrac.x = 1.0 / ray.direction.x;
    dirfrac.y = 1.0 / ray.direction.y;
    dirfrac.z = 1.0 / ray.direction.z;

    t1 := (box.min.x - ray.origin.x)*dirfrac.x;
    t2 := (box.max.x - ray.origin.x)*dirfrac.x;
    t3 := (box.min.y - ray.origin.y)*dirfrac.y;
    t4 := (box.max.y - ray.origin.y)*dirfrac.y;
    t5 := (box.min.z - ray.origin.z)*dirfrac.z;
    t6 := (box.max.z - ray.origin.z)*dirfrac.z;

    tmin := max(max(min(t1, t2), min(t3, t4)), min(t5, t6));
    tmax := min(min(max(t1, t2), max(t3, t4)), max(t5, t6));

    // if tmax < 0, ray (line) is intersecting AABB, but the whole AABB is behind us
    // if tmin > tmax, ray doesn't intersect AABB
    if tmax < 0 || tmin > tmax
    {
        return false, 0;
    }

    return true, tmin;
}
