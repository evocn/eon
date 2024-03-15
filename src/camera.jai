// Everett
// Camera
// Alex Hartford
// June 2023

camera : struct
{
	FLY_SPEED  :: 4.0;
	ROTATION_SPEED :: 0.3;
	ROTATION_SMOOTHING :: 0.3;

	fov := 70.0;

	position     : Vector3;
	euler_angles : Vector3;
	rotation     : Quaternion;
	rotation_input : Vector2;

	transform   : Matrix4;
    view        : Matrix4;
    projection  : Matrix4;

    ignore_next_call : bool;
}

set_camera :: (position : Vector3, euler_angles : Vector3) {
    camera.position = position;
    camera.euler_angles = euler_angles;
}

set_camera :: () {
    set_camera(settings.default_camera_position, settings.default_camera_angles);
}

//
//

drive_free_camera :: () {
    camera.ignore_next_call = true;
    SDL_ShowCursor(0);
    SDL_SetRelativeMouseMode(SDL_TRUE);
}

drive_editor_camera :: () {
    SDL_ShowCursor(1);
    SDL_SetRelativeMouseMode(SDL_FALSE);
    SDL_WarpMouseInWindow(window, cast(s32)window_width / 2, cast(s32)window_height / 2);
}

drive_game_camera :: () {
    set_camera();
    camera.ignore_next_call = true;
    SDL_ShowCursor(0);
    SDL_SetRelativeMouseMode(SDL_TRUE);
}

//
//

resolve_camera_inputs :: (delta_time : float)
{
    using camera;

	mouse_delta : Vector2;
	move_input  : Vector3;
	move_speed  : float;
	if program_state.mode == .VIEW {
        mouse_delta_x, mouse_delta_y : s32;
        mouse_button_delta := SDL_GetRelativeMouseState(*mouse_delta_x, *mouse_delta_y);
		mouse_delta = xy(xx mouse_delta_x, xx mouse_delta_y);

        if ignore_next_call {
            ignore_next_call = false;
            mouse_delta = .{};
        }
    }

	if program_state.mode == .VIEW
    || program_state.mode == .EDITOR
    {
		move_speed = FLY_SPEED;
		if input.button_2 then move_speed *= 10;
		move_input.x = cast(float)input.right - cast(float)input.left;
		move_input.y = cast(float)input.button_4 - cast(float)input.button_3;
		move_input.z = cast(float)input.down - cast(float)input.up;
		move_input = rotate(unit_vector(move_input), rotation);
	}
    
    // Position
	position += move_input * move_speed * delta_time;

    // Orientation
	rotation_input = lerp(rotation_input, mouse_delta, ROTATION_SMOOTHING);
	delta := rotation_input * ROTATION_SPEED;
	euler_angles.x += radians(delta.x);
	euler_angles.y += radians(delta.y);
	euler_angles.y = clamp(euler_angles.y, radians(-89.0), radians(89.0));
	yaw : Quaternion;
	set_from_axis_and_angle(*yaw, 0, -1, 0, euler_angles.x);
	pitch : Quaternion;
	set_from_axis_and_angle(*pitch, -1, 0, 0, euler_angles.y);
	rotation = yaw * pitch;

    // Set Transforms
	transform = make_translation_matrix4(position) * rotation_matrix(Matrix4, rotation);

    view = inverse(transform);

	aspect_ratio := window_width / cast(float)window_height;
	projection = make_projection_matrix(radians(fov), aspect_ratio, 1.0, 1000.0);
}
