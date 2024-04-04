// Everett
// Mesh
// Alex Hartford
// March 2024

MAX_WEIGHTS :: 4;
MAX_JOINTS :: 100;
#assert MAX_JOINTS <= 0x7fff "MAX_JOINTS can't exceed the max of an s16, since we use that for joint ids.";

Mesh :: struct {
    vertices : [..] Vertex;
    indices  : [..] u32;
    vao, vbo, ibo : GLuint;

    texture : Texture;

    using skeleton : Skeleton;
}

Vertex :: struct
{
	position : Vector3;
	normal   : Vector3;
    uv       : Vector2;
	weights  : Vector4;
    joints   : [4] s16;
}


Skeleton :: struct
{
	joints : [..] Joint;
	name_to_joint_id : Table(string, s16);

    //

    Joint :: struct
    {
        id : s16;

        local_bind_transform    : Matrix4; // The joint in the rest position, relative to the parent's coordinate system
        inverse_bind_transform  : Matrix4; // The inverse of the matrix of the joint in model space.

        parent : *Joint;
    }
}

////////////////////////////////////////////////////////////////////////////////

// This function is a little wonky, but it's essentially calculating a mesh's extents, as transformed by a specific rotation, scale, translation.
// The goal is to have easy bounding boxes for most stuff which doesn't matter that much,
// Specifically for editor functionality (picking and such).
find_extents :: (using mesh : Mesh, transform: Transform) -> low : Vector3, high : Vector3 {
    low : Vector3;
    high: Vector3;

    for untransformed_vertex : vertices {
        // Only rotate and scale, since we're going off the untranslated mesh.
        vertex := rotate(untransformed_vertex.position, transform.orientation) * transform.scale;

        low.x   = min(vertex.x, low.x);
        low.y   = min(vertex.y, low.y);
        low.z   = min(vertex.z, low.z);

        high.x  = max(vertex.x, high.x);
        high.y  = max(vertex.y, high.y);
        high.z  = max(vertex.z, high.z);
    }

    return low + transform.position, high + transform.position;
}

////////////////////////////////////////////////////////////////////////////////
// OpenGL Stuff

draw_mesh :: (using mesh : Mesh)
{
	glBindVertexArray(vao);
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);

	glDrawElements(GL_TRIANGLES, cast(u32)indices.count, GL_UNSIGNED_INT, null);
}

init_mesh_rendering_objects :: (using mesh : *Mesh)
{
	glGenVertexArrays(1, *vao);
	glGenBuffers(1, *vbo);
	glGenBuffers(1, *ibo);
	glBindVertexArray(vao);

	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glBufferData(GL_ARRAY_BUFFER, size_of(Vertex) * vertices.count, vertices.data, GL_STATIC_DRAW);

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, size_of(u32) * indices.count, indices.data, GL_STATIC_DRAW);

	glEnableVertexAttribArray(0); // Position
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, size_of(Vertex), cast(*void)0);
	glEnableVertexAttribArray(1); // Normal
	glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, size_of(Vertex), cast(*void)size_of(Vector3));
	glEnableVertexAttribArray(2); // UVs
	glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, size_of(Vertex), cast(*void)(2 * size_of(Vector3)));

	glEnableVertexAttribArray(3); // Weights
	glVertexAttribPointer(3, 4, GL_FLOAT, GL_FALSE, size_of(Vertex), cast(*void)(2 * size_of(Vector3) + size_of(Vector2)));
	glEnableVertexAttribArray(4); // Joints
	glVertexAttribIPointer(4, 4, GL_SHORT, size_of(Vertex), cast(*void)(size_of(Vector4) + 2 * size_of(Vector3) + size_of(Vector2)));

	glBindVertexArray(0);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	glBindBuffer(GL_UNIFORM_BUFFER, 0);
}

////////////////////////////////////////////////////////////////////////////////
// Night Mesh

create_mesh_from_night_mesh :: (filename : string) -> Mesh {
    a: Allocator;
    a.proc = flat_pool_allocator_proc;
    a.data = *mesh_pool;

    mesh : Mesh;
    mesh.indices.allocator = a;
    mesh.vertices.allocator = a;
    mesh.joints.allocator = a;

    success := load_night_mesh(tprint("%/%", meshes_path, filename), *mesh);
    if !success {
        log_error("Unable to load night_mesh file.\n");
        return mesh;
    }
    init_mesh_rendering_objects(*mesh);
    return mesh;
}

load_night_mesh :: (full_path : string, mesh: *Mesh) -> bool {
	parse_joint :: (handler : *Text_File_Handler, mesh : *Mesh, joint : *Skeleton.Joint) -> bool
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

	parse_vertex :: (handler : *Text_File_Handler, mesh : *Mesh, vertex : *Vertex) -> bool
	{
		ok : bool;
		vertex.position, ok = parse_vector3 (handler);
		if !ok
			return false;
		vertex.normal, ok = parse_vector3 (handler);
		if !ok
			return false;
		vertex.uv, ok = parse_vector2 (handler);
		if !ok
			return false;
		vertex.weights, ok = parse_vector4 (handler);
		if !ok
			return false;
		vertex.joints, ok = parse_int_tuple (handler, 4, s16);
		if !ok
			return false;

		return true;
	}

	parse_triangle :: (handler : *Text_File_Handler, mesh : *Mesh, index : s64) -> bool
	{
		tri, ok := parse_int_tuple (handler, 3, u32);
		if !ok
			return false;
		mesh.indices[index + 0] = tri[0];
		mesh.indices[index + 1] = tri[1];
		mesh.indices[index + 2] = tri[2];
		return true;
	}

	handler : Text_File_Handler;
	defer deinit (*handler);

    handler.do_version_number = false; // @TODO: Maybe we should version these files...

	found_slash, dir, basename := split_from_right (full_path, #char "/");
	if !found_slash then basename = full_path;
    start_file (*handler, basename, full_path, optional = false);

	if handler.failed
		return false;

	ok : bool;
	mesh.joints.count, ok = parse_ident_and_int_line (*handler, "joint_count");
	if !ok
		return false;
	if mesh.joints.count > MAX_JOINTS
		return error_out (handler, "Too many joints (expected at most %, got %).", MAX_JOINTS, mesh.joints.count);

	mesh.vertices.count, ok = parse_ident_and_int_line (*handler, "vertex_count");
	if !ok
		return false;

	triangle_count : s64;
	triangle_count, ok = parse_ident_and_int_line (*handler, "triangle_count");
	if !ok
		return false;
	mesh.indices.count = triangle_count * 3;

	// Allocate all the data in one batch, so everything is contiguous
	all_data := alloc (size_of (Skeleton.Joint) * mesh.joints.count
		+ size_of (Vertex) * mesh.vertices.count
		+ size_of (u32) * mesh.indices.count
	);

	init (*mesh.name_to_joint_id, mesh.joints.count);
	mesh.joints.data   = all_data;
	mesh.vertices.data = cast (*Vertex) (mesh.joints.data + mesh.joints.count);
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
	if found
		return error_out (handler, "Expected EOF.");

	return true;
}

////////////////////////////////////////////////////////////////////////////////
// GLTF

/*
create_mesh_from_gltf :: (filename : string, $debug := false) -> Mesh {
    mesh, success := load_gltf(tprint("%/%", meshes_path, filename), debug);
    if !success {
        log_error("Unable to load gltf file.\n");
        return mesh;
    }
    init_mesh_rendering_objects(*mesh);
    return mesh;
}

load_gltf :: (full_path : string, $debug := false) -> Mesh, bool {
    a: Allocator;
    a.proc = flat_pool_allocator_proc;
    a.data = *mesh_pool;

    mesh : Mesh;
    mesh.indices.allocator = a;
    mesh.vertices.allocator = a;
    mesh.skeleton.joints.allocator = a;

    positions:  [..] float;
    normals:    [..] float;
    uvs:        [..] float;

    skinned : bool;
    joints:     [..] s16;
    weights:    [..] float;
    matrices:   [..] float;

    {
        data := gltf_parse_file(full_path);
        defer gltf_free(*data);

        #if debug {
            gltf_debug_print(data);
        }

        gltf_load_buffers(*data);
        accessors := data.meshes[0].primitives[0].attributes;
        indices_accessor := data.meshes[0].primitives[0].indices_accessor;

        read_buffer_from_accessor(*data, data.accessors[accessors.position_accessor], *positions);
        read_buffer_from_accessor(*data, data.accessors[accessors.normal_accessor], *normals);
        read_buffer_from_accessor(*data, data.accessors[accessors.texcoord_0_accessor], *uvs);
        read_buffer_from_accessor(*data, data.accessors[indices_accessor], *mesh.indices);

        // Skeleton?
        if data.skins.count {
            skinned = true;
            read_buffer_from_accessor(*data, data.accessors[accessors.joints_accessor], *joints);
            read_buffer_from_accessor(*data, data.accessors[accessors.weights_accessor], *weights);

            // Parse a Skeleton!
            inverse_bind_matrices_accessor := data.skins[0].inverse_bind_matrices;
            read_buffer_from_accessor(*data, data.accessors[inverse_bind_matrices_accessor], *matrices);

            if data.skins[0].joints.count > MAX_JOINTS
                assert(false, tprint("Too many joints (expected at most %, got %).", MAX_JOINTS, data.skins[0].joints.count));

            array_resize(*mesh.skeleton.joints, data.skins[0].joints.count);
            for * joint, joint_id : mesh.skeleton.joints {
                joint.id = cast(s16)joint_id;

                view := array_view(matrices, joint_id * 16, 16);
                joint.inverse_bind_transform = make_matrix4(..view);

                node := data.nodes[joint_id];
                table_add(*mesh.skeleton.name_to_joint_id, copy_string(node.name,, a), joint.id);
                parent_id := node.parent;

                if parent_id == -1 || parent_id >= mesh.skeleton.joints.count {
                    joint.parent = null;
                    joint.local_bind_transform = node.local_transform;
                    joint.calculated = true;
                }
                else {
                    joint.parent = *mesh.skeleton.joints[parent_id];
                    joint.calculated = false;
                }
            }

            queue : [..] *Joint;
            for * joint : mesh.skeleton.joints {
                if !joint.calculated then array_add(*queue, joint);
            }
            while queue.count > 0 {
                joint := pop(*queue);
                node := data.nodes[joint.id];
                if joint.parent.calculated {
                    joint.local_bind_transform = joint.parent.local_bind_transform * node.local_transform;
                    joint.calculated = true;
                }
                else {
                    array_insert_at(*queue, joint, 0);
                }
            }
        }

        // Texture?
        if data.images.count {
            mesh.texture = load_texture_from_memory(data.images[0].data);
        }
    }

    // Apply the contiguous data to my vertex structure.
    for 0..(positions.count / 3 - 1) {
        new_vertex : Vertex;
        new_vertex.position = Vector3.{positions[3 * it + 0], positions[3 * it + 1], positions[3 * it + 2]};
        new_vertex.normal   = Vector3.{normals[3 * it + 0], normals[3 * it + 1], normals[3 * it + 2]};
        new_vertex.uv = Vector2.{uvs[2 * it + 0], uvs[2 * it + 1]};

        if skinned {
            new_vertex.joints = s16.[joints[4 * it + 0], joints[4 * it + 1], joints[4 * it + 2], joints[4 * it + 3]];
            new_vertex.weights = Vector3.{weights[4 * it + 0], weights[4 * it + 1], weights[4 * it + 2]};

            //print("% %\n", new_vertex.joints, new_vertex.weights);
        }

        array_add(*mesh.vertices, new_vertex);
    }

    array_reset(*positions);
    array_reset(*normals);
    array_reset(*uvs);
    array_reset(*joints);
    array_reset(*weights);
    array_reset(*matrices);

    return mesh, true;
}
*/
