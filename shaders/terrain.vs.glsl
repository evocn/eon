// Eon
// Terrain VS
// Alex Hartford
// April 2024

#version 460 core

layout (location = 0) in vec3 VertexPosition;
layout (location = 1) in vec3 VertexNormal;
layout (location = 2) in vec2 VertexUV;

////////////////////////////////////////////////////////////////////////////////
// The usual suspects

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

uniform mat4 light_space_matrix;

////////////////////////////////////////////////////////////////////////////////
// Outputs

out vec3 fragment_position;
out vec3 fragment_normal;
out vec2 texture_coordinates;
out vec4 fragment_position_in_light_space;

////////////////////////////////////////////////////////////////////////////////

void main() {
    vec3 object_space_position  = VertexPosition;
    vec3 object_space_normal    = VertexNormal;

    vec3 model_space_position   = vec3(model * vec4(object_space_position, 1.0));
	vec3 model_space_normal     = object_space_normal.xyz;

    gl_Position = projection * view * vec4(model_space_position, 1.0);

    texture_coordinates = VertexUV;
    fragment_position_in_light_space = light_space_matrix * vec4(model_space_position, 1.0);
    fragment_position   = model_space_position;
    fragment_normal     = model_space_normal;
}
