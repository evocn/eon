// Eon
// Utils
// Alex Hartford
// June 2023

Direction :: enum {
    NORTH;
    SOUTH;
    EAST;
    WEST;
}

//
//

// This is incomplete, and won't work for matrices that have shear.
// In that case we would use a polar decomposition, so this assumes
// your matrix does not have shear.
decompose_transform :: inline (mat : Matrix4) -> translation : Vector3, rotation : Quaternion, scale : Vector3
{
	translation := xyz (
		mat._14,
		mat._24,
		mat._34
	);
	rotation := get_rotation (mat);
	scale := xyz (
		length (xyz (mat._11, mat._21, mat._31)),
		length (xyz (mat._12, mat._22, mat._32)),
		length (xyz (mat._13, mat._23, mat._33))
	);

	return translation, rotation, scale;
}


radians :: (degrees: float) -> float {
    return degrees * PI / 180.0;
}

// OpenGL
//

print_gl_errors :: (str := "-") {
    if dont_check_for_gl_errors_anymore then return;

    current_error : GLenum;
    current_error = glGetError();
    while current_error != GL_NO_ERROR {
        dont_check_for_gl_errors_anymore = true;

        log_error("OpenGL Error(%) = %\n", str, current_error);

        current_error = glGetError();
    }
}

dont_check_for_gl_errors_anymore : bool;
