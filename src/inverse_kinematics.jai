

// Inverse Kinematics
//

fabrik :: (using line: *Line, target : Vector3) -> Line, bool {
    // Check if it's too far to reach.
    maximum_line_length : float;
    for i : 1..points.count-1 {
        maximum_line_length += length(points[i] - points[i-1]);
    }
    if maximum_line_length < length(points[0] - target) {
        print("Unreachable target %. Maximum length the line could reach was %, while the point was % away.\n", 
              target, maximum_line_length, length(points[0] - target));
        return line, false;
    }

    // Perform forward/backward inverse kinematics.
    current_line : Line;
    array_copy(*current_line.points, line.points);

    solved : bool;
    forward : bool;
    while !solved {
        if forward
            solved = forward_inverse_kinematics(*current_line, targets.points[targeting_index]);
        else
            solved = backward_inverse_kinematics(*current_line, targets.points[targeting_index]);
        forward = !forward;
    }
    return current_line, true;
}

forward_ik :: (using line: *Line, target : Vector3, distance_threshold := 0.0001) -> bool {
    distances : [..] float;
    for i : 0..points.count-2 array_add(*distances, distance(points[i], points[i+1]));

    for i : 0..points.count-2 {
        direction := normalize(points[i+1] - points[i]);
        points[i+1] = points[i] + direction * distances[i];
    }

    if distance(points[points.count-1], target) <= distance_threshold
        return true;
    else
        return false;
}

backward_ik :: (using line: *Line, target : Vector3, distance_threshold := 0.0001) -> bool {
    distances : [..] float;
    for i : 0..points.count-2 array_add(*distances, distance(points[i], points[i+1]));

    initial_point_zero := points[0];
    points[points.count-1] = target;

    for < i : points.count-1..1 {
        direction := normalize(points[i-1] - points[i]);
        points[i-1] = points[i] + direction * distances[i-1];
    }

    if distance(points[0], initial_point_zero) <= distance_threshold
        return true;
    else
        return false;
}

