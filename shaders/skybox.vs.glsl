#version 460 core

layout (location = 0) in vec3 VertexPosition;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

out vec3 tex_coords;

void main() {
    // Cubemaps use vertex position for texturing.
    tex_coords = VertexPosition;
    // set position to be behind everything.
    vec4 position = projection * view * model * vec4(VertexPosition, 1.0);
    gl_Position = position.xyww;
}
