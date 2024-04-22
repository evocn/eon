// Everett
// Main FS
// Alex Hartford
// June 2023

#version 460 core

out vec4 FragColor;

////////////////////////////////////////////////////////////////////////////////

in vec3 fragment_position;
in vec3 fragment_normal;
in vec2 texture_coordinates;
in vec4 fragment_position_in_light_space;

////////////////////////////////////////////////////////////////////////////////

uniform vec4 color_override;

uniform vec3 light_direction;

uniform sampler2D diffuse_texture;
uniform sampler2D shadow_map;

uniform int normals_mode;

////////////////////////////////////////////////////////////////////////////////

float calculate_shadow(vec4 light_space_position) {
    // perform perspective divide
    vec3 projection_coordinates = light_space_position.xyz / light_space_position.w;
    projection_coordinates = projection_coordinates * 0.5 + 0.5; 

    float closest_depth = texture(shadow_map, projection_coordinates.xy).r;
    float current_depth = projection_coordinates.z;

    // For shadow acne
    float bias = 0.005;

    // Linear PCF
    // @TODO: Do some noise here!
    float shadow = 0.0;
    vec2 texel_size = 1.0 / textureSize(shadow_map, 0);
    for(int x = -1; x <= 1; ++x)
    {
        for(int y = -1; y <= 1; ++y)
        {
            float pcf_depth = texture(shadow_map, projection_coordinates.xy + vec2(x, y) * texel_size).r;
            shadow += current_depth - bias > pcf_depth ? 1.0 : 0.0;
        }
    }
    shadow /= 9.0;

    // For oversampling
    if(projection_coordinates.z > 1.0) {
        shadow = 0.0;
    }
    return shadow;
}

////////////////////////////////////////////////////////////////////////////////

void main()
{
    vec3 base_texture_color = vec3(texture(diffuse_texture, texture_coordinates));
    vec3 base_color = mix(base_texture_color, color_override.xyz, color_override.a);

    float diffuse_amount = clamp(dot(fragment_normal, light_direction), 0.0f, 1.0f);

    float shadow_amount = calculate_shadow(fragment_position_in_light_space);

    vec3 diffuse_color = base_color * diffuse_amount;
    vec3 ambient_color = base_color * 0.3;

    FragColor.xyz = 
        (
            ambient_color + 
            diffuse_color
        )
        * (1.0 - shadow_amount)
    ;

    // Normals
    if (normals_mode != 0) {
        FragColor.xyz = fragment_normal;
    }

    // UVs
    //FragColor.xy = texture_coordinates;

    FragColor.a = 1.0;
}
