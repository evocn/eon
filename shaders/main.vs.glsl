
#version 330 core

layout (location = 0) in vec3  VertexPosition;
layout (location = 1) in vec3  VertexNormal;
layout (location = 2) in vec2  VertexUV;
layout (location = 3) in vec4  VertexWeights;
layout (location = 4) in ivec4 VertexJoints;

////////////////////////////////////////////////////////////////////////////////
// The usual suspects

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

uniform mat4 light_space_matrix;

////////////////////////////////////////////////////////////////////////////////
// Animation

uniform int animated;

const int MAX_JOINTS  = 100;
const int MAX_WEIGHTS = 4;
layout (std140) uniform Block {
	mat4 skinning_matrices[MAX_JOINTS];
};

////////////////////////////////////////////////////////////////////////////////
// Outputs

out vec3 fragment_position;
out vec3 fragment_normal;
out vec2 texture_coordinates;
out vec4 fragment_position_in_light_space;

////////////////////////////////////////////////////////////////////////////////

void main() {
    vec3 animation_space_position   = vec3(0);
    vec3 animation_space_normal     = vec3(0);

    if (animated == 1) {
        for (int i = 0; i < MAX_WEIGHTS; i++) {
            int joint_index = VertexJoints[i];

            float weight;
            if (i == MAX_WEIGHTS - 1) weight = 1.0 - (VertexWeights.x + VertexWeights.y + VertexWeights.z);
                                 else weight = VertexWeights[i];

            mat4 skinning_matrix = skinning_matrices[joint_index];
            vec4 joint_space_position = skinning_matrix * vec4(VertexPosition, 1.0);
            vec4 joint_space_normal   = skinning_matrix * vec4(VertexNormal, 0.0);
            animation_space_position  += joint_space_position.xyz * weight;
            animation_space_normal    += joint_space_normal.xyz   * weight;
        }
    }
    else {
        animation_space_position    = VertexPosition;
        animation_space_normal      = VertexNormal;
    }

    vec3 object_space_position = vec3(model * vec4(animation_space_position, 1.0));
	vec3 object_space_normal = animation_space_normal.xyz;

    gl_Position = projection * view * vec4(object_space_position, 1.0);

    texture_coordinates = VertexUV;
    fragment_position_in_light_space = light_space_matrix * vec4(object_space_position, 1.0);
    fragment_position   = object_space_position;
    fragment_normal     = object_space_normal;
}
