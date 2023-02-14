#define PIXELATION_SIZE 1.6

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 texel_size;

void main() {
    float d_x = (texture2D(gm_BaseTexture, v_vTexcoord + vec2(texel_size.x, 0.0)).w + (texture2D(gm_BaseTexture, v_vTexcoord + vec2(texel_size.x, 0.0)).z / 255.0) -
            (texture2D(gm_BaseTexture, v_vTexcoord - vec2(texel_size.x, 0.0)).w + (texture2D(gm_BaseTexture, v_vTexcoord - vec2(texel_size.x, 0.0)).z / 255.0))) * 0.5;
    float d_y = (texture2D(gm_BaseTexture, v_vTexcoord + vec2(0.0, texel_size.y)).w + (texture2D(gm_BaseTexture, v_vTexcoord + vec2(0.0, texel_size.y)).z / 255.0) -
            (texture2D(gm_BaseTexture, v_vTexcoord - vec2(0.0, texel_size.y)).w + (texture2D(gm_BaseTexture, v_vTexcoord - vec2(0.0, texel_size.y)).z / 255.0))) * 0.5;
    
    vec3 light_direction = normalize(vec3(1.0, 1.0, -0.5));
    float steepness = 0.3;
    vec3 normal = normalize(cross(normalize(vec3(steepness, 0.0, d_x)), normalize(vec3(0.0, steepness, d_y))));
    float lightness = clamp(pow(max(dot(normal, -light_direction), 0.0), 1.0), 0.0, 1.0);
    
    gl_FragColor = v_vColour * vec4(mix(vec3(0.2, 0.16, 0.1), vec3(0.9, 0.88, 0.8), lightness * 1.5), clamp((texture2D(gm_BaseTexture, v_vTexcoord).w - 0.1) * 4.0 + 0.5, 0.0, 1.0));
}
