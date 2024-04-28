// Eon
// Post-Processing FS
// Alex Hartford
// April 2024

#version 460 core

out vec4 FragColor;

in vec3 eye_to_fragment;
in vec2 texture_coordinates;

uniform vec3 camera_position;

////////////////////////////////////////////////////////////////////////////////

uniform sampler2D color_texture;
uniform sampler2D depth_texture;

////////////////////////////////////////////////////////////////////////////////
// Fog

uniform int     fog;
uniform vec3    fog_color;
uniform float   fog_density;

// Recalculate fragment position from depth texture
vec3 get_fragment_position_from_depth_buffer(float depth_from_zbuffer) {

    // Bring depth back through the view-projection matrix.
    float z = 0.0f;
    {
        float f = 1000.0;
        float n = 1.0;

        float p33 = (f + n) / (n - f);
        float p34 = (-2 * f * n) / (f - n);

        float depth = depth_from_zbuffer;
        z = (-1 * p34) / (depth + p33);

        // @TODO: Should be able to simplify if we have a hardcoded frustum n / f to something more like this:
        //z = -2.0625 / (depth - 1.0025);
    }

    vec3 camera_direction = vec3(0, 0, 1);

    float u = z / dot(normalize(camera_direction), normalize(eye_to_fragment));
    vec3 fragment_world_space_position = camera_position + (u * eye_to_fragment);

    return fragment_world_space_position;
}

////////////////////////////////////////////////////////////////////////////////

void main()
{
    vec3 color_from_cbuffer = texture(color_texture, texture_coordinates).xyz;
    float depth_from_zbuffer = texture(depth_texture, texture_coordinates).x;

    vec3 fragment_world_space_position = get_fragment_position_from_depth_buffer(depth_from_zbuffer);

    // Calculate Fog Integral
    float integral = exp(-1 * (fog_density * length(fragment_world_space_position)));

    ////////////////////////////////////////////////////////////////////////////////
    // Generate the color from all these inputs

    vec3 color = color_from_cbuffer;

    if (fog != 0) {
        color = mix(fog_color, color, integral);
    }

    FragColor.xyz = 
        color
    ;

    FragColor.a = 1.0;
}
