// Everett
// Character Controller
// Alex Hartford
// March 2024

Transform :: struct {
    using position  : Vector3;
    orientation     : Quaternion;
    scale           := 1.0;
}

Character_Controller :: struct {
    movement_speed : float = 1.0;
    rotation_speed : float = 0.3;
}

update_camera_with_input :: (using camera: *Camera) {
}

update_transforms_with_input :: (using entity : *Entity, delta_time : float) {
    // Position
    {
        move_input : Vector3;
        move_input.x = cast(float)input.right.is_down - cast(float)input.left.is_down;
        move_input.z = cast(float)input.down.is_down - cast(float)input.up.is_down;
        move_input = rotate(unit_vector(move_input), orientation);

        move_speed := movement_speed;
        if input.west.is_down then move_speed *= 10;

        position += move_input * move_speed * delta_time;
    }
}
