varying vec4 v_vColour;
uniform vec4 blend;

void main() {
    gl_FragColor = v_vColour * blend;
}
