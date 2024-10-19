// varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float index;

// uniform int autotile_type;
// uniform int autotile_bitmask_in[256];
// uniform int autotile_bitmask_out[256];

void main() {
    gl_FragColor = vec4(index + 1., 0., 0., 1.);
}
