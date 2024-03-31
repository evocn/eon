// Everett
// Mesh
// Alex Hartford
// June 2023

MAX_WEIGHTS :: 4;
MAX_JOINTS :: 100;
#assert MAX_JOINTS <= 0x7fff "MAX_JOINTS can't exceed the max of an s16, since we use that for joint ids.";

Mesh :: struct {
    vertices : [..] Vertex;
    indices  : [..] u32;
    vao, vbo, ibo : GLuint;

    texture : Texture;

    skeleton : Skeleton;
}

Vertex :: struct
{
	position : Vector3;
	normal   : Vector3;
    uv       : Vector2;
	weights  : Vector3;
	joints   : [4] s16;
}


Skeleton :: struct
{
	joints : [..] Joint;
	name_to_joint_id : Table(string, s16);
}

Joint :: struct
{
    id : s16;

    // The joint in the rest position, relative to the parent's coordinate system
    local_bind_transform : Matrix4;
    // The inverse of the matrix of the joint in model space.
    inverse_bind_transform : Matrix4;

    parent : *Joint;
}

//
//

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

//
//

draw_mesh :: (using mesh : Mesh)
{
	glBindVertexArray(vao);
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);

	glDrawElements(GL_TRIANGLES, cast(u32)indices.count, GL_UNSIGNED_INT, null);
}

bind_skinning_matrices :: (skinning_matrices : [] Matrix4, shader : Shader) {
	assert(skinning_matrices.count <= MAX_JOINTS, "Skinning matrices array cannot have more than % elements.", MAX_JOINTS);

    for skinning_matrices {
        set_mat4(shader, tprint("skinning_matrices[%]", it_index), it);
    }
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

	glEnableVertexAttribArray(0);
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, size_of(Vertex), cast(*void)0);
	glEnableVertexAttribArray(1);
	glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, size_of(Vertex), cast(*void)size_of(Vector3));
	glEnableVertexAttribArray(2);
	glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, size_of(Vertex), cast(*void)(2 * size_of(Vector3)));

	glEnableVertexAttribArray(3);
	glVertexAttribPointer(3, 3, GL_FLOAT, GL_FALSE, size_of(Vertex), cast(*void)(2 * size_of(Vector3) + size_of(Vector2)));
	glEnableVertexAttribArray(4);
	glVertexAttribIPointer(4, 4, GL_SHORT, size_of(Vertex), cast(*void)(3 * size_of(Vector3) + size_of(Vector2)));

	glBindVertexArray(0);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	glBindBuffer(GL_UNIFORM_BUFFER, 0);
}

create_mesh_from_gltf :: (filename : string, $debug := false) -> Mesh {
    mesh, success := load_gltf(tprint("%/%", meshes_path, filename), debug);
    if !success {
        log_error("Unable to load gltf file.\n");
        return mesh;
    }
    init_mesh_rendering_objects(*mesh);
    return mesh;
}

//
//

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

                for view {
                    joint.inverse_bind_transform = make_matrix4(..view);
                }

                node := data.nodes[joint_id];
                table_add(*mesh.skeleton.name_to_joint_id, copy_string(node.name,, a), joint.id);

                parent_id := node.parent;

                // @TODO: This seems sus. Not sure why we should be accepting joints with parents apparently outside the range of the array that aren't -1.
                // It seems to work with gltf, but either there's a weird hitch in the spec here, or it indexes from 1, or something else wacky going on.
                // In any case, hopefully this works for now, and if it's broken, then this is likely the culprit!
                if parent_id == -1 || parent_id >= mesh.skeleton.joints.count {
                    joint.parent = null;
                    joint.local_bind_transform = node.local_transform;
                }
                else {
                    joint.parent = *mesh.skeleton.joints[parent_id];
                    joint.local_bind_transform = joint.parent.local_bind_transform * node.local_transform;
                }
            }
        }

        // Animation?
        if data.animations.count > 0 {
            if debug {
                for animation : data.animations {
                    print("\n\n============== This is animation %: =================\n", it_index);
                    for channel : animation.channels {
                        using channel;
                        print("Channel: (Sampler %) (target node %) (target property %)\n", 
                            sampler, target.node, target.property);
                    }
                    for sampler : animation.samplers {
                        using sampler;
                        print("Sampler: (input %) (output %) (interpolation %)\n", 
                            input, output, interpolation);
                    }
                }

                print("Pog\n");
            }

            for gltf_animation : data.animations {
                sampled_animation : Joint_Animation;

                for channel : gltf_animation.channels {
                    if channel.target.property == {
                        case .TRANSLATION;
                        case .ROTATION;
                        case .SCALE;
                    }
                    // Get the stuff out of the sampler which this channel is looking at
                    {
                        sampler := gltf_animation.samplers[channel.sampler];

                        timestamps: [..] float;
                        outputs:    [..] float;

                        read_buffer_from_accessor(*data, data.accessors[sampler.input], *timestamps);
                        read_buffer_from_accessor(*data, data.accessors[sampler.output], *outputs);
                    }
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
