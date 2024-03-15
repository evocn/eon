#version 330 core
out vec4 FragColor;

in vec3 fragment_position;
in vec3 fragment_normal;
in vec2 texture_coordinates;
in vec4 fragment_position_in_light_space;

uniform vec4 color_override;

uniform sampler2D diffuse_texture;
uniform sampler2D shadow_map;

//
//

float calculate_shadow(vec4 light_space_position) {
    // perform perspective divide
    vec3 projection_coordinates = light_space_position.xyz / light_space_position.w;
    projection_coordinates = projection_coordinates * 0.5 + 0.5; 

    float closest_depth = texture(shadow_map, projection_coordinates.xy).r;
    float current_depth = projection_coordinates.z;

    // For shadow acne
    float bias = 0.005;

    // Linear PCF
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

//
//

void main()
{
    vec3 base_texture_color = vec3(texture(diffuse_texture, texture_coordinates));
    vec3 base_color = mix(base_texture_color, color_override.xyz, color_override.a);

    float shadow_amount = calculate_shadow(fragment_position_in_light_space);
    FragColor.xyz = base_color * (1.0 - shadow_amount);
    FragColor.a = 1.0;
}
