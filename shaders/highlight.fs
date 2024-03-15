#version 330 core
out vec4 FragColor;

uniform float highlight;

void main()
{
    FragColor = vec4(1.0, 1.0, highlight, 1.0);
}
