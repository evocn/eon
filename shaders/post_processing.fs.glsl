// Everett
// Post-Processing FS
// Alex Hartford
// April 2024

#version 460 core

out vec4 FragColor;

in vec2 texture_coordinates;
in vec3 eye_to_fragment;

////////////////////////////////////////////////////////////////////////////////

uniform vec3 camera_position;

uniform sampler2D color_texture;
uniform sampler2D depth_texture;

vec3 fog_color;

////////////////////////////////////////////////////////////////////////////////

void main()
{
    vec3 color;

    vec3 color_from_cbuffer = texture(color_texture, texture_coordinates).xyz;
    vec3 color_from_zbuffer = texture(depth_texture, texture_coordinates).xyz;

    ////////////////////////////////////////////////////////////////////////////////
    // Recalculate fragment position from depth texture

    float z = 0.0f;
    {
        float f = 1000.0;
        float n = 1.0;

        float p33 = (f + n) / (n - f);
        float p34 = (-2 * f * n) / (f - n);

        float depth = color_from_zbuffer.x;
        //z = (-1 * p34) / (depth + p33);
        z = -2.0625 / (depth - 1.0025);
    }

    vec3 camera_direction = vec3(0, 0, 1);

    float u = z / dot(normalize(camera_direction), normalize(eye_to_fragment));
    vec3 fragment_world_space_position = camera_position + (u * eye_to_fragment);

    float density = 0.01;
    float integral = exp(-1 * (density * length(fragment_world_space_position)));

    ////////////////////////////////////////////////////////////////////////////////
    // Generate the color!

    vec3 fog_color = vec3(0.2, 0.2, 0.5);

    color = color_from_cbuffer;

    vec3 color_of_fragment_with_fog_applied = 
        mix(fog_color, color, integral)
    ;

    FragColor.xyz = 
        color_of_fragment_with_fog_applied
        //fragment_world_space_position
        //color_from_cbuffer
        //(eye_to_fragment + 1) * 0.5
    ;

    FragColor.a = 1.0;
}
