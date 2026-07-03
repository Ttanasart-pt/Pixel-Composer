varying vec4 v_vColour;
uniform vec4 blend;
uniform vec4 obj_color;

void main() {
    gl_FragColor = v_vColour * blend * obj_color;
}
