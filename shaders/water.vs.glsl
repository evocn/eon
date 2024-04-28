// Eon
// Water VS
// Alex Hartford
// April 2024

#version 460 core

layout (location = 0) in vec3 VertexPosition;

////////////////////////////////////////////////////////////////////////////////
// The usual suspects

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

////////////////////////////////////////////////////////////////////////////////
// Outputs

out vec3 fragment_position;
out vec4 clip_space_position;

////////////////////////////////////////////////////////////////////////////////

void main() {
    fragment_position = vec3(model * vec4(VertexPosition, 1.0f));
    clip_space_position = projection * view * model * vec4(VertexPosition, 1.0f);

    gl_Position = projection * view * model * vec4(VertexPosition, 1.0f);
}
