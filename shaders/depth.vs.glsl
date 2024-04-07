#version 330 core
layout (location = 0) in vec3  VertexPosition;
layout (location = 3) in vec4  VertexWeights;
layout (location = 4) in ivec4 VertexJoints;

////////////////////////////////////////////////////////////////////////////////
// The usual suspects

uniform mat4 light_space_matrix;
uniform mat4 model;

////////////////////////////////////////////////////////////////////////////////
// Animation

uniform int animated;

const int MAX_JOINTS  = 100;
const int MAX_WEIGHTS = 4;
layout (std140, row_major) uniform Block {
	mat4 skinning_matrices[MAX_JOINTS];
};

////////////////////////////////////////////////////////////////////////////////

void main()
{
    vec3 object_space_position  = vec3(0);
    vec3 object_space_normal    = vec3(0);

    if (animated == 1) {
        for (int i = 0; (i < MAX_WEIGHTS) && (VertexJoints[i] != -1); i++)
        {
            int joint_index = VertexJoints[i];

            float weight = VertexWeights[i];

            mat4 skinning_matrix = skinning_matrices[joint_index];
            vec4 bind_space_position = skinning_matrix * vec4(VertexPosition, 1.0);
            object_space_position  += bind_space_position.xyz * weight;
        }
    }
    else 
    {
        object_space_position    = VertexPosition;
    }

    vec3 model_space_position   = vec3(model * vec4(object_space_position, 1.0));

    gl_Position = light_space_matrix * vec4(model_space_position, 1.0);
}  
