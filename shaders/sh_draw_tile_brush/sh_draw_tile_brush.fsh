// varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float index;

void main() {
    gl_FragColor = vec4(index + 1., 0., 0., 1.);
}
