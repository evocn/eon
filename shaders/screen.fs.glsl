// Everett
// Screen FS
// Alex Hartford
// April 2024

#version 460 core

out vec4 FragColor;

in vec2 texture_coordinates;

uniform sampler2D the_texture;

void main()
{
    FragColor = texture(the_texture, texture_coordinates);
} 
