// Eon
// Text FS
// Alex Hartford
// April 2024

#version 460 core
out vec4 FragColor;

in vec2 texture_coordinates;

uniform sampler2D text;
uniform vec4 color;

void main()
{    
    vec4 sampled = vec4(1.0, 1.0, 1.0, texture(text, texture_coordinates).r);
    FragColor = color * sampled;
}  
