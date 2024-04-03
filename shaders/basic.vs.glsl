#version 330 core
layout (location = 0) in vec3 VertexPosition;
layout (location = 1) in vec4 VertexColor;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

out vec4 Color;

void main()
{
    gl_Position = projection * view * model * vec4(VertexPosition, 1.0);
    Color = VertexColor;
}
