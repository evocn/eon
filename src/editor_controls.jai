// Everett
// Editor Controls
// Alex Hartford
// March 2024

////////////////////////////////////////////////////////////////////////////////
// Picking Entities

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

    mouse_position_in_world_space := inverse(program_state.camera.projection * program_state.camera.view) * mouse_position_in_clip_space;

    ray : Ray;
    ray.origin = program_state.camera.position;
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

// Returns the length from the middle of the box to its corner.
extent :: (using box: Box) -> float {
    return length(max - min) / 2;
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

////////////////////////////////////////////////////////////////////////////////

/*
Plane :: struct {
    known_point : Vector3;
    normal : Vector3;
}

is_on_plane :: (point : Vector3, plane : Plane) -> bool {
    return 0 == dot(plane.normal, point - plane.known_point);
}

intersection :: (ray : Ray, plane : Plane) -> bool, t: float {
    d_dot_n := dot(ray.direction, plane.normal);
    if d_dot_n == 0 then return false, -1; // perpendicular to the normal. never intersects.

    t := dot(plane.known_point - ray.origin, plane.normal) / d_dot_n;
    return t >= 0, t;
}

test_intersection :: () {
    ray := Ray.{.{250, 300, 0}, .{0, -1, 0}};

    plane := Plane.{.{}, .{1, 1, 0}};

    collided, t := intersection(ray, plane);
    print("%, %\n", collided, t);
}

#run test_intersection();
*/
