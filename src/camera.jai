// Eon
// Camera
// Alex Hartford
// March 2024

Camera_System :: struct {
    cameras : [..] *Camera;
    camera_pool : Flat_Pool;
}

Camera :: struct
{
    kind : enum #complete {
        STATIC;
        FLYING;
        WALKING;
    }

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

resolve_camera_inputs :: (camera: *Camera, delta_time : float) {
    if #complete camera.kind == {
        case .STATIC;   ;
        case .FLYING;   resolve_camera_flying_inputs(cast(*Camera_Flying)camera, delta_time);
        case .WALKING;  resolve_camera_walking_inputs(cast(*Camera_Walking)camera, delta_time);
    }
}

////////////////////////////////////////////////////////////////////////////////

program_drive_free_camera :: () {
    program_state.camera = program_state.editor_camera;

    program_state.camera.ignore_next_call = true;
    SDL_ShowCursor(0);
    SDL_SetRelativeMouseMode(SDL_TRUE);
}

program_drive_editor_camera :: () {
    program_state.camera = program_state.editor_camera;

    SDL_ShowCursor(1);
    SDL_SetRelativeMouseMode(SDL_FALSE);
    SDL_WarpMouseInWindow(window, cast(s32)window_width / 2, cast(s32)window_height / 2);
}

program_drive_game_camera :: () {
    program_state.camera = program_state.game_camera;

    program_state.camera.ignore_next_call = true;
    SDL_ShowCursor(0);
    SDL_SetRelativeMouseMode(SDL_TRUE);
}

////////////////////////////////////////////////////////////////////////////////

set_camera :: (camera : *Camera, position : Vector3, euler_angles : Vector3) {
    camera.position = position;
    camera.euler_angles = euler_angles;
}

////////////////////////////////////////////////////////////////////////////////
// Flying Camera

Camera_Flying :: struct {
    using #as camera: Camera;
    kind = .FLYING;

    MOVEMENT_SPEED  :: 10.0;
    SLOWER_SPEED    :: 4.0;
    FASTER_SPEED    :: 100.0;
    ROTATION_SPEED  :: 0.3;
    ROTATION_SMOOTHING :: 0.3;
}

// @TODO: Clean this function up! Shouldn't rely on the program_state!
resolve_camera_flying_inputs :: (using camera_flying: *Camera_Flying, delta_time : float)
{
    assert(camera_flying != null);

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
        move_speed = MOVEMENT_SPEED;
        if input.west.is_down then move_speed = FASTER_SPEED;
        if input.east.is_down then move_speed = SLOWER_SPEED;
        move_input.x = cast(float)input.right.is_down - cast(float)input.left.is_down;
        move_input.y = cast(float)input.north.is_down - cast(float)input.south.is_down;
        move_input.z = cast(float)input.down.is_down - cast(float)input.up.is_down;
        move_input = rotate(unit_vector(move_input), rotation);
    }

    // Position
    {
        position += move_input * move_speed * delta_time;
    }

    // Orientation
    {
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
    }

    // Set Transforms
    transform = make_translation_matrix4(position) * rotation_matrix(Matrix4, rotation);

    view = inverse(transform);

    aspect_ratio := window_width / cast(float)window_height;
    projection = make_projection_matrix(radians(fov), aspect_ratio, 1.0, 1000.0);
}

////////////////////////////////////////////////////////////////////////////////
// Walking Camera

Camera_Walking :: struct {
    using #as camera: Camera;
    kind = .WALKING;

    MOVEMENT_SPEED  :: 10.0;
    SLOWER_SPEED    :: 4.0;
    FASTER_SPEED    :: 100.0;
    ROTATION_SPEED  :: 0.3;
    ROTATION_SMOOTHING :: 0.3;
}

resolve_camera_walking_inputs :: (using camera_walking: *Camera_Walking, delta_time : float)
{
    assert(camera_walking != null);

    mouse_delta : Vector2;
    move_input  : Vector3;
    move_speed  : float;

    // Mouse Input
    {
        mouse_delta_x, mouse_delta_y : s32;
        mouse_button_delta := SDL_GetRelativeMouseState(*mouse_delta_x, *mouse_delta_y);
        mouse_delta = xy(xx mouse_delta_x, xx mouse_delta_y);

        if ignore_next_call {
            ignore_next_call = false;
            mouse_delta = .{};
        }
    }

    // Keyboard Input
    {
        move_speed = MOVEMENT_SPEED;
        if input.west.is_down then move_speed = FASTER_SPEED;
        if input.east.is_down then move_speed = SLOWER_SPEED;
        move_input.x = cast(float)input.right.is_down - cast(float)input.left.is_down;
        move_input.z = cast(float)input.down.is_down  - cast(float)input.up.is_down;

        omnidirectional_move_input := rotate(move_input, rotation);

        omnidirectional_move_input.y = 0;
        move_input = unit_vector(omnidirectional_move_input);
    }
    
    // Position
    {
        position += move_input * move_speed * delta_time;
    }

    // Orientation
    {
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
    }

    // Set Transforms
    transform = make_translation_matrix4(position) * rotation_matrix(Matrix4, rotation);

    view = inverse(transform);

    aspect_ratio := window_width / cast(float)window_height;
    projection = make_projection_matrix(radians(fov), aspect_ratio, 1.0, 1000.0);
}

// Polar coordinate transform from pitch/yaw to a Cartesian vector
polar_to_vector :: (pitch : float, yaw : float) -> Vector3 {
    result : Vector3;
    result.x = cos(radians(yaw)) * cos(radians(pitch));
    result.y = sin(radians(pitch));
    result.z = sin(radians(yaw)) * cos(radians(pitch));
    return result;
}
