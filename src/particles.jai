

// Instancing Code... Maybe?
/*
glBindVertexArray(VAO_INSTANCED);

    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, size_of(Vertex) * 4, cast(*void)VERTICES.data, GL_STATIC_DRAW);

    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, size_of(Vertex), null);
    glEnableVertexAttribArray(0);

    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, size_of(Vertex), cast(*void)(3 * size_of(float)));
    glEnableVertexAttribArray(1);

    // Bind and set instance buffer data (empty for now, you will update this every frame or whenever instance data changes)
    glBindBuffer(GL_ARRAY_BUFFER, VBO_INSTANCED);
    glBufferData(GL_ARRAY_BUFFER, size_of(Matrix4) * MAX_INSTANCES, null, GL_DYNAMIC_DRAW);  // Reserve space for MAX_INSTANCES

    // Instance attribute pointers (assuming Matrix4 is made up of 4 Vector4's)
    for i: 0..3 {
        glVertexAttribPointer(xx (2 + i), 4, GL_FLOAT, GL_FALSE, size_of(Matrix4), cast(*void) (i * size_of(Vector4)));
        glEnableVertexAttribArray(xx (2 + i));
        glVertexAttribDivisor(xx (2 + i), 1);  // this makes it instanced
    }

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, size_of(u32) * 6, cast(*void)INDICES.data, GL_STATIC_DRAW);

    glBindVertexArray(0);
*/
