// Everett
// Mesh
// Alex Hartford
// June 2023

MESH_VERSION :: 1;
meshes_path :: "assets/meshes";

Vertex :: struct
{
	position : Vector3;
	normal   : Vector3;
    uv       : Vector2;
}

Mesh :: struct {
    points  : [] Vector3;
    uvs     : [] Vector2;
    normals : [] Vector3;
	union {
		faces   : [] Face;
		indices : [] u32;
	}
	vao, vbo, ibo : GLuint;
}

Skin_Vertex :: struct
{
	position : Vector3;
	normal   : Vector3;

	// We can have at most 4 weights, but they have to sum up
	// to 1, so the last one can be calculated and we don't store it.
	weights  : Vector3;
	joints   : [4]s16;
}

Skinned_Mesh :: struct
{
    name : string;
	#as using skeleton : Skeleton;
	vertices : [] Skin_Vertex;
	indices  : [] u32;
	vao, vbo, ibo : GLuint;
}

MAX_WEIGHTS :: 4;
MAX_JOINTS :: 1000;
#assert MAX_JOINTS <= 0x7fff "MAX_JOINTS can't exceed the max of an s16, since we use that for joint ids.";

Skeleton :: struct
{
	Joint :: struct
	{
		id : s16;
		// This is the matrix of the joint in the rest position, relative to the parent's coordinate system
		local_bind_transform : Matrix4;
		// This is the inverse of the matrix of the joint in model space.
		// Why we have this matrix is explained in anim.jai:generate_skinning_matrices
		inverse_bind_transform : Matrix4;
		parent : *Joint;
	}

	name_to_joint_id : Table(string, s16);
	joints : [] Joint;	// Root joint is joints[0]
}

new_skinned_mesh :: (filename : string) -> *Skinned_Mesh {
    mesh := New(Skinned_Mesh);
    loaded := load_mesh_from_file(mesh, tprint("%/%", meshes_path, filename));
    if loaded {
        mesh.name = path_strip_extension(filename);
        init_mesh_rendering_objects(mesh);
        return mesh;
    }
    else {
        log_error("Could not load mesh %.", basename);
        free(mesh);
        return null;
    }
}

//
//

#scope_file
load_mesh_from_file :: (mesh : *Skinned_Mesh, filename : string) -> bool
{
	parse_joint :: (handler : *Text_File_Handler, mesh : *Skinned_Mesh, joint : *Skeleton.Joint) -> bool
	{
		name, ok := consume_next_line (handler);
		if !ok
			return false;
		joint.id = cast (s16) (joint - mesh.joints.data);
		table_add (*mesh.name_to_joint_id, copy_string (name), joint.id);
		joint.local_bind_transform, ok = parse_matrix4 (handler);

		// Parse parent id
		parent_id : s16;
		parent_id, ok = parse_int (handler, s16);
		if !ok
			return false;
		// Set the inverse bind transform to the model space transform first.
		// We will invert the matrices after all the joints have been parsed.
		if parent_id >= 0
		{
			if parent_id >= mesh.joints.count
  			    return error_out (handler, "Invalid parent joint id.");
            parent := *mesh.joints[parent_id];
			joint.parent = parent;
			joint.inverse_bind_transform = parent.inverse_bind_transform * joint.local_bind_transform;
		} else {
			joint.parent = null;
			joint.inverse_bind_transform = joint.local_bind_transform;
		}

		return true;
	}

	parse_vertex :: (handler : *Text_File_Handler, mesh : *Skinned_Mesh, vertex : *Skin_Vertex) -> bool
	{
		ok : bool;
		vertex.position, ok = parse_vector3(handler);
		if !ok return false;

		vertex.normal, ok = parse_vector3(handler);
		if !ok return false;

		vertex.weights, ok = parse_vector3(handler);
		if !ok return false;

		vertex.joints, ok = parse_int_tuple(handler, 4, s16);
		if !ok return false;

		return true;
	}

	parse_triangle :: (handler : *Text_File_Handler, mesh : *Skinned_Mesh, index : s64) -> bool
	{
		tri, ok := parse_int_tuple (handler, 3, u32);
		if !ok return false;

		mesh.indices[index + 0] = tri[0];
		mesh.indices[index + 1] = tri[1];
		mesh.indices[index + 2] = tri[2];
		return true;
	}

	handler : Text_File_Handler;
	defer deinit(*handler);

	found_slash, dir, basename := split_from_right (filename, #char "/");
	if !found_slash then basename = filename;
	start_file(*handler, basename, filename, optional = false);
	if handler.failed return false;

	if handler.version != MESH_VERSION
		return error_out(handler, "Invalid version number.");

	ok : bool;
	mesh.joints.count, ok = parse_ident_and_int_line (*handler, "joint_count");
	if !ok return false;

	if mesh.joints.count > MAX_JOINTS
		return error_out (handler, "Too many joints (expected at most %, got %).", MAX_JOINTS, mesh.joints.count);

	mesh.vertices.count, ok = parse_ident_and_int_line (*handler, "vertex_count");
	if !ok return false;

	triangle_count : s64;
	triangle_count, ok = parse_ident_and_int_line (*handler, "triangle_count");
	if !ok return false;

	mesh.indices.count = triangle_count * 3;

	// Allocate all the data in one batch, so everything is contiguous
	all_data := alloc (size_of (Skeleton.Joint) * mesh.joints.count
		+ size_of (Skin_Vertex) * mesh.vertices.count
		+ size_of (u32) * mesh.indices.count
	);

	init(*mesh.name_to_joint_id, mesh.joints.count);
	mesh.joints.data   = all_data;
	mesh.vertices.data = cast (*Skin_Vertex) (mesh.joints.data + mesh.joints.count);
	mesh.indices.data  = cast (*u32) (mesh.vertices.data + mesh.vertices.count);
	
	// Parse joints
	line, found := consume_next_line (*handler);
	if line != "joints:"
		return error_out (handler, "Expected 'joints:', got '%' instead.", line);
	for * mesh.joints
		if !parse_joint (*handler, mesh, it)
			return error_out (handler, "Could not parse joint %.", it_index);
	    // Inverse all the bind transforms we calculated while parsing the joints
	for * mesh.joints
		it.inverse_bind_transform = inverse (it.inverse_bind_transform);

	// Parse vertices
	line, found = consume_next_line (*handler);
	if line != "vertices:"
		return error_out (handler, "Expected 'vertices:', got '%' instead.", line);
	for * mesh.vertices
		if !parse_vertex (*handler, mesh, it)
			return error_out (handler, "Could not parse vertex %.", it_index);

	// Parse triangles
	line, found = consume_next_line (*handler);
	if line != "triangles:"
		return error_out (handler, "Expected 'triangles:', got '%' instead.", line);
	for i : 0..triangle_count - 1
		if !parse_triangle (*handler, mesh, i * 3)
			return error_out (handler, "Could not parse triangle %.", i);

	line, found = consume_next_line (*handler);
	if found return error_out (handler, "Expected EOF.");

	return true;
}

// =============================================================================
// OpenGL

init_mesh_rendering_objects :: (using mesh : *Skinned_Mesh)
{
	glGenVertexArrays(1, *vao);
	glGenBuffers(1, *vbo);
	glGenBuffers(1, *ibo);
	glBindVertexArray(vao);
	defer glBindVertexArray(0);

	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	defer glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBufferData(GL_ARRAY_BUFFER, size_of(Skin_Vertex) * vertices.count, vertices.data, GL_STATIC_DRAW);

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
	defer glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, size_of(u32) * indices.count, indices.data, GL_STATIC_DRAW);

	glEnableVertexAttribArray(0);
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, size_of(Skin_Vertex), cast(*void)0);
	glEnableVertexAttribArray(1);
	glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, size_of(Skin_Vertex), cast(*void)size_of(Vector3));
	glEnableVertexAttribArray(2);
	glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, size_of(Skin_Vertex), cast(*void)(2 * size_of(Vector3)));
	glEnableVertexAttribArray(3);
	glVertexAttribIPointer(3, 4, GL_SHORT, size_of(Skin_Vertex), cast(*void)(3 * size_of(Vector3)));
}

/*
make_mesh_soa :: (using mesh : *Mesh, draw_mode := GL_STATIC_DRAW) {
    has_ibo := xx mesh.indices;
    points_count  := cast(u32)mesh.points.count;
    indices_count := cast(u32)mesh.indices.count;

	glGenVertexArrays(1, *vao);
	glGenBuffers(1, *vbo);

	glBindVertexArray(vao);
	defer glBindVertexArray(0);

	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	defer glBindBuffer(GL_ARRAY_BUFFER, 0);

	if has_ibo {
		glGenBuffers(1, *ibo);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
        defer glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, mesh.indices.count * size_of(u32), mesh.indices.data, xx draw_mode);
	}

	s_points := mesh.points.count * size_of(Vector3);
	s_normals:= mesh.normals.count * size_of(Vector3);
	s_uvs    := mesh.uvs.count * size_of(Vector2);
	vbo_size := s_points + s_uvs + s_normals;
	glBufferData(GL_ARRAY_BUFFER, vbo_size, null, xx draw_mode);

	glEnableVertexAttribArray(0);
	glBufferSubData(GL_ARRAY_BUFFER, 0, s_points, mesh.points.data);
	glVertexAttribPointer(0, xx (size_of(Vector3) / size_of(float)), GL_FLOAT, GL_FALSE, 0, cast(*void)(0));

	glEnableVertexAttribArray(1);
	glBufferSubData(GL_ARRAY_BUFFER, s_points, s_normals, mesh.normals.data);
	glVertexAttribPointer(1, xx (size_of(Vector3) / size_of(float)), GL_FLOAT, GL_FALSE, 0, cast(*void)(s_points));

	glEnableVertexAttribArray(2);
	glBufferSubData(GL_ARRAY_BUFFER, s_points + s_normals, s_uvs, mesh.uvs.data);
	glVertexAttribPointer(2, xx (size_of(Vector2) / size_of(float)), GL_FLOAT, GL_FALSE, 0, cast(*void)(s_points + s_normals));
}
*/

/*
init_rendering_objects :: (animation_shader : Shader) -> bool
{
	// Check if we can store enough data for the skinning
	// information in a shader uniform block.
	uniform_block_size : s32;
	glGetIntegerv(GL_MAX_UNIFORM_BLOCK_SIZE, *uniform_block_size);
	assert(uniform_block_size >= MAX_JOINTS * size_of(Matrix4),
		"OpenGL implementation does not allow storing more than % bytes in uniform block, but we need at least % for skinning information. Recompile the program with a smaller MAX_JOINTS value.",
		uniform_block_size, MAX_JOINTS * size_of(Matrix4));

	// We need to bind the block in the mesh shader to a binding point
	// that we define to be GL_BIG_DATA_UNIFORM_BINDING
	big_data_uniform_index := glGetUniformBlockIndex(animation_shader, "Big_Data");
	glUniformBlockBinding(animation_shader, big_data_uniform_index, GL_BIG_DATA_UNIFORM_BINDING);

	// Create big data uniform buffer object
	glGenBuffers(1, *g_big_data_ubo);
	glBindBuffer(GL_UNIFORM_BUFFER, g_big_data_ubo);
	// Allocate the data for the uniform buffer. This data will
	// be filled with all the skinning matrices.
	glBufferData(GL_UNIFORM_BUFFER, size_of (Matrix4) * MAX_JOINTS, null, GL_DYNAMIC_DRAW);
	glBindBuffer(GL_UNIFORM_BUFFER, 0);
	glBindBufferBase(GL_UNIFORM_BUFFER, GL_BIG_DATA_UNIFORM_BINDING, g_big_data_ubo);

	return true;
}
*/
