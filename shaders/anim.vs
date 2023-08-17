#version 330 core
layout (location = 0) in vec3 VertexPosition;
layout (location = 1) in vec3 VertexNormal;
layout (location = 2) in vec3 BoneWeights;
layout (location = 3) in ivec4 BoneIDs;
//layout (location = 2) in vec2 TextureCoordinates;

const int MAX_JOINTS  = 1000;
const int MAX_WEIGHTS = 4;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

out vec3 Fragment_Position;
out vec3 View_Position;
out vec3 Normal;

void main ()
{
    Fragment_Position = vec3(model * vec4(VertexPosition, 1.0f));
    View_Position = vec3(view * model * vec4(VertexPosition, 1.0f));
    Normal = normalize(mat3(transpose(inverse(model))) * VertexNormal);

	gl_Position = projection * view * vec4(Fragment_Position, 1.0);
}

/*
// A simple uniform variable cannot hold a lot of data,
// so we use a uniform block to store the skinning information.
// A uniform block can hold more data, and we check if the
// OpenGL implementation allows us to store enough at the
// start of the program.
layout (std140) uniform Big_Data
{
	mat4 SkinningMatrices[MAX_JOINTS];
};
*/

/*
	vec3 model_position = vec3(0);
	vec3 model_normal = vec3(0);
	if(BoneIDs[0] == -1)
	{
		model_position = VertexPosition;
		model_normal   = VertexNormal;
	}
	for (int i = 0; i < MAX_WEIGHTS && BoneIDs[i] != -1; i += 1)
	{
		int bone_id = BoneIDs[i];
		float weight;
		if (i == MAX_WEIGHTS - 1)
			weight = 1 - (BoneWeights.x + BoneWeights.y + BoneWeights.z);
		else
			weight = BoneWeights[i];
		mat4 skinning_matrix = SkinningMatrices[bone_id];
		vec3 pose_position = (skinning_matrix * vec4(VertexPosition, 1)).xyz;
		model_position += pose_position * weight;
		vec3 pose_normal = (skinning_matrix * vec4(VertexNormal, 0)).xyz;
		model_normal += pose_normal * weight;
	}
	gl_Position = projection * view * model * vec4(model_position, 1);
	Normal = model_normal.xyz;
*/
