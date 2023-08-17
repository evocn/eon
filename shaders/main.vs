#version 330 core
layout (location = 0) in vec3 VertexPosition;
layout (location = 1) in vec3 VertexNormal;
layout (location = 2) in vec2 VertexUV;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

uniform mat4 light_space_matrix;

out vec3 fragment_position;
out vec4 fragment_position_in_light_space;

void main() {
    fragment_position = vec3(model * vec4(VertexPosition, 1.0));

    gl_Position = projection * view * vec4(fragment_position, 1.0);

    fragment_position_in_light_space = light_space_matrix * vec4(fragment_position, 1.0);
}
