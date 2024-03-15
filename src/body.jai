// Everett
// Body
// Alex Hartford
// August 2023

Transform :: struct {
    using position  : Vector3;
    orientation     : Quaternion;
    scale           := 1.0;
}

Character_Body :: struct {
    movement_speed : float = 1.0;
	rotation_speed : float = 0.3;
}

update_transforms_with_input :: (using entity : *Entity, delta_time : float) {
    // Position
    {
        move_input : Vector3;
        move_input.x = cast(float)input.right - cast(float)input.left;
        move_input.z = cast(float)input.down - cast(float)input.up;
        move_input = rotate(unit_vector(move_input), orientation);

        move_speed := movement_speed;
        if input.button_2 then move_speed *= 10;

        position += move_input * move_speed * delta_time;
    }
}
