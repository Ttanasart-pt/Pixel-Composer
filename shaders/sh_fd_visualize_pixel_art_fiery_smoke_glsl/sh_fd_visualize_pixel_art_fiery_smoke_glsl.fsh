#define PIXELATION_SIZE 1.6

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 texel_size;

void main() {
    float reaction_coordinate = texture2D(gm_BaseTexture, floor(v_vTexcoord / (texel_size * PIXELATION_SIZE)) * (texel_size * PIXELATION_SIZE)).w;

    gl_FragColor.rgb = vec3(1.0, 0.2, 0.0);
    if (reaction_coordinate < 0.2) gl_FragColor.rgb = vec3(0.3);
    if (reaction_coordinate > 0.37) gl_FragColor.rgb = vec3(1.0, 0.8, 0.0);
    if (reaction_coordinate > 0.65) gl_FragColor.rgb = vec3(1.0, 1.0, 1.0);
    gl_FragColor.a = float(reaction_coordinate > 0.05);
    
    gl_FragColor *= v_vColour;
}
