#version 330 core
out vec4 FragColor;

in vec3 fragment_position;
in vec4 fragment_position_in_light_space;

uniform vec4 color;

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

    float shadow = current_depth - bias > closest_depth ? 1.0 : 0.0;  

    // For oversampling
    if(projection_coordinates.z > 1.0) {
        shadow = 0.0;
    }
    return shadow;
}

void main()
{
    float shadow = calculate_shadow(fragment_position_in_light_space);
    FragColor = vec4(1.0 - shadow, 0.0, 0.0, 1.0);
}
