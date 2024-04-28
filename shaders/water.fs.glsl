// Eon
// Water FS
// Alex Hartford
// April 2024

out vec4 FragColor;

in vec3 fragment_position;
in vec4 clip_space_position;

uniform sampler2D reflection_texture;
uniform sampler2D refraction_texture;

void main()
{
    vec2 ndc = clip_space_position.xy / clip_space_position.w;
    vec2 refraction_coordinates = (ndc + vec2(1.0f)) / 2.0f;
    vec2 reflection_coordinates = vec2(refraction_coordinates.x, -refraction_coordinates.y);

    vec3 reflection_color = texture(reflection_texture, reflection_coordinates).xyz;
    vec3 refraction_color = texture(refraction_texture, refraction_coordinates).xyz;

    FragColor.xyz = reflection_color;

    // Combine
    //FragColor = mix(reflection_color, refraction_color, 0.5f);

    FragColor.a = 1.0;
}
