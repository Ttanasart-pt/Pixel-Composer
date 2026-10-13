varying vec4 v_vColour;

uniform float index;
uniform float varient;

void main() {
    gl_FragColor = vec4(index + 1., varient, 0., 1.);
}
