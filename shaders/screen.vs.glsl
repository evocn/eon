// Eon
// Screen VS
// Alex Hartford
// April 2024

#version 460 core

layout (location = 0) in vec3 VertexPosition;

out vec2 texture_coordinates;
out vec3 eye_to_fragment;

////////////////////////////////////////////////////////////////////////////////

void main()
{
    texture_coordinates = (VertexPosition.xy + vec2(1.0)) * 0.5;
    eye_to_fragment = (VertexPosition + vec3(0, 0, -1));

    gl_Position = vec4(VertexPosition, 1.0);
}
