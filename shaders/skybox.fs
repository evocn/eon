#version 330 core

out vec4 outColor;

in vec3 tex_coords;

uniform samplerCube skybox_texture;
uniform float interp_factor;

void main()
{
    outColor = texture(skybox_texture, tex_coords);
}
