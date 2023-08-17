#version 330 core
layout (location = 0) in vec3 VertexPosition;

out vec2 texture_coordinates;

void main()
{
    texture_coordinates = (VertexPosition.xy + vec2(1.0)) * 0.5;
    gl_Position = vec4(VertexPosition, 1.0);
}
