#version 330 core
layout (location = 0) in vec3  VertexPosition;
layout (location = 1) in vec3  VertexNormal;
layout (location = 2) in vec2  VertexUV;
layout (location = 3) in vec3  VertexWeights;
layout (location = 4) in ivec4 VertexJoints;

//
//

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

uniform mat4 light_space_matrix;


const int MAX_JOINTS = 100;
uniform mat4 skinning_matrices[MAX_JOINTS];
uniform int animated;

//
//

out vec3 fragment_position;
out vec3 fragment_normal;
out vec2 texture_coordinates;
out vec4 fragment_position_in_light_space;

void main() {
	vec3 model_position = vec3(0);
	vec3 model_normal = vec3(0);

    if(animated == 1) {
        for(int i = 0; i < 4 && VertexJoints[i] != -1; i += 1) {
            int joint_id = VertexJoints[i];

            float weight;
            if (i == 3)
                weight = 1 - (VertexWeights.x + VertexWeights.y + VertexWeights.z);
            else
                weight = VertexWeights[i];

            mat4 skinning_matrix = skinning_matrices[joint_id];

            vec3 pose_position = (skinning_matrix * vec4(VertexPosition, 1)).xyz;
            model_position += pose_position * weight;

            vec3 pose_normal = (skinning_matrix * vec4(VertexNormal, 0)).xyz;
            model_normal += pose_normal * weight;
        }
    }
    else {
		model_position = VertexPosition;
		model_normal   = VertexNormal;
    }

    fragment_position = vec3(model * vec4(model_position, 1.0));
	fragment_normal = model_normal.xyz;

    gl_Position = projection * view * vec4(fragment_position, 1.0);
    texture_coordinates = VertexUV;

    fragment_position_in_light_space = light_space_matrix * vec4(fragment_position, 1.0);
}

