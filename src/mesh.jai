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
}

Joint :: struct
{
    id : s16;
    parent : *Joint;

    local_bind_transform    : Matrix4; // Joint   at rest, in its parent's local space.
    inverse_bind_transform  : Matrix4; // Inverse at rest, in model space.

    // This is always a little confusing, so here's a decent explanation:
    /*
        A Joint's *Local Bind Transform* represents a Joint's transform from its parent.
            It isn't directly used once we've calculated the Inverse Bind Transform, besides to reset to Bind Pose, 
            since setting the Skinning Matrix to this mimics the Bind Pose's normal hierarchy.

        A Joint's *Inverse Bind Transform* is the matrix you can use to transform from Model Space into that Joint's Space.

        Since Vertices are defined in Model Space, we must:
            1. Convert Vertices from Model Space to a Joint Space.
            2. Apply Joint Transforms for the Joint's pose.
            3. Apply PVM Transforms as usual

        Skinning Matrix :
        {
            A *Skinning Matrix* is the difference between the Bind Pose and the actual pose we want, in Bind Space.
            > A mesh displaying in Bind Position will have all its Skinning Matrices be the Identity Matrix.

            In order to generate the Skinning Matrix of a Joint, you need...
                the Model Space Transform of the pose, 
                and the Inverse Bind Transform of the Joint.

            To get the Model Space Transform of the pose, you multiply:
                1. The pose's sample data             (In Parent-Local Space)
                2. The Parent's Model Space Transform (In Parent's Model Space)
            This gets us into Model Space.

            In order for our Model Space vertices to be transformed by the Pose's Pose Space samples,
            we apply the Skinning Matrix, which both converts the Model Space vertex into Bind Space, and also applies the Pose Transform to finish us off in Pose Space.
        }

        Summary : 
        {
            Joint Pose (Bind Space)
                |
                * - Parent's Model Space Transform (Bind Space -> Model Space)
                v
            (Model Space)
                |
                * - Inverse Bind Transform (Model Space -> Bind Space)
                v
            Skinning Matrix (Bind Space)


            Vertex (Model Space)
                |
                * - Skinning Matrix (Bind Space -> Pose Space)
                v
            (Pose Space)
                |
                * - Projection, View, Model (Pose Space -> World Space)
                v
            (World Space)
        }

        conclusion :
        {
            Vertex * Inverse Bind Transform * Sampled Pose Transform * PVM
            (Model) ->      (Bind)         ->        (Pose)       -> (World)
        }
    */
}

////////////////////////////////////////////////////////////////////////////////

// This function computes a minimum bounding box for a transformed (rotate / scale) mesh.
// Translations are applied at later stages, since we want them to be relative to the entity this describes.
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

create_mesh_from_file :: (filename : string) -> Mesh {
    a: Allocator;
    a.proc = flat_pool_allocator_proc;
    a.data = *mesh_pool;

    mesh : Mesh;
    mesh.indices.allocator = a;
    mesh.vertices.allocator = a;
    mesh.joints.allocator = a;

    success := load_mesh_from_file(tprint("%/%", meshes_path, filename), *mesh);
    if !success {
        log_error("Unable to load .mesh file.\n");
        return mesh;
    }
    init_mesh_rendering_objects(*mesh);
    return mesh;
}

load_mesh_from_file :: (full_path : string, mesh: *Mesh) -> bool {

    parse_joint :: (handler : *Text_File_Handler, mesh : *Mesh, joint : *Joint) -> bool {
        name, ok := consume_next_line(handler);
        if !ok then return false;

        joint.id = cast(s16)(joint - mesh.joints.data);
        table_add(*mesh.name_to_joint_id, copy_string(name), joint.id);
        joint.local_bind_transform, ok = parse_matrix4(handler);

        // Parse parent id
        parent_id : s16;
        parent_id, ok = parse_int(handler, s16);
        if !ok then return false;

        // @NOTE: Temporarily setting this to the model space transform first.
        // Must wait until all the joints have been parsed to invert matrices.
        if parent_id >= 0
        {
            if parent_id >= mesh.joints.count then return error_out (handler, "Invalid parent joint id.");

            parent := *mesh.joints[parent_id];
            joint.parent = parent;
            joint.inverse_bind_transform = parent.inverse_bind_transform * joint.local_bind_transform;
        }
        else 
        {
            joint.parent = null;
            joint.inverse_bind_transform = joint.local_bind_transform;
        }

        return true;
    }

    parse_vertex :: (handler : *Text_File_Handler, mesh : *Mesh, vertex : *Vertex) -> bool {
        ok : bool;

        vertex.position, ok = parse_vector3(handler);           if !ok then return false;
        vertex.normal, ok = parse_vector3(handler);             if !ok then return false;
        vertex.uv, ok = parse_vector2(handler);                 if !ok then return false;
        vertex.weights, ok = parse_vector4(handler);            if !ok then return false;
        vertex.joints, ok = parse_int_tuple(handler, 4, s16);   if !ok then return false;

        return true;
    }

    parse_triangle :: (handler : *Text_File_Handler, mesh : *Mesh, index : s64) -> bool {
        tri, ok := parse_int_tuple (handler, 3, u32);
        if !ok then return false;

        mesh.indices[index + 0] = tri[0];
        mesh.indices[index + 1] = tri[1];
        mesh.indices[index + 2] = tri[2];

        return true;
    }

    handler : Text_File_Handler;
    defer deinit(*handler);

    found_slash, dir, basename := split_from_right(full_path, #char "/");
    if !found_slash then basename = full_path;
    start_file(*handler, basename, full_path, optional = false);
    if handler.failed then return false;
    if handler.version != VERSION then return error_out(handler, "Invalid version number.");

    ok : bool;

    // Get Counts
    triangle_count : s64;
    {
        mesh.joints.count, ok = parse_ident_and_int_line (*handler, "joint_count");
        if !ok then return false;
        if mesh.joints.count > MAX_JOINTS then return error_out (handler, "Too many joints (expected at most %, got %).", MAX_JOINTS, mesh.joints.count);

        mesh.vertices.count, ok = parse_ident_and_int_line (*handler, "vertex_count");
        if !ok then return false;

        triangle_count, ok = parse_ident_and_int_line (*handler, "triangle_count");
        if !ok then return false;

        mesh.indices.count = triangle_count * 3;
    }

    // Allocate Space to store data
    {
        // Allocate all the data in one batch, so everything is contiguous
        all_data := alloc(size_of (Joint) * mesh.joints.count
                        + size_of(Vertex) * mesh.vertices.count
                        + size_of   (u32) * mesh.indices.count
                         );

        init(*mesh.name_to_joint_id, mesh.joints.count);
        mesh.joints.data   = all_data;
        mesh.vertices.data = cast(*Vertex) (mesh.joints.data   + mesh.joints.count  );
        mesh.indices.data  = cast(*u32)    (mesh.vertices.data + mesh.vertices.count);
    }


    line : string; found : bool;

    // Parse joints
    {
        line, found = consume_next_line(*handler);
        if line != "joints:" then return error_out(handler, "Expected 'joints:', got '%' instead.", line);

        for * mesh.joints
            if !parse_joint(*handler, mesh, it) then return error_out(handler, "Could not parse joint %.", it_index);


        // Inverse all the bind transforms we calculated while parsing the joints
        for * mesh.joints
            it.inverse_bind_transform = inverse(it.inverse_bind_transform);
    }

    // Parse vertices
    {
        line, found = consume_next_line (*handler);
        if line != "vertices:" then return error_out (handler, "Expected 'vertices:', got '%' instead.", line);

        for * mesh.vertices
            if !parse_vertex (*handler, mesh, it) then return error_out (handler, "Could not parse vertex %.", it_index);
    }

    // Parse triangles
    {
        line, found = consume_next_line (*handler);
        if line != "triangles:" then return error_out (handler, "Expected 'triangles:', got '%' instead.", line);

        for i : 0..triangle_count - 1
            if !parse_triangle (*handler, mesh, i * 3) then return error_out (handler, "Could not parse triangle %.", i);
    }

    line, found = consume_next_line (*handler);
    if found then return error_out (handler, "Expected EOF.");

    return true;
}
