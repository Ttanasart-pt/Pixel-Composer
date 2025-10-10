varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
    float inner  = step(v_vTexcoord.x * v_vTexcoord.x, v_vTexcoord.y);
    if(inner == 0.) discard;
    gl_FragColor = v_vColour;
}
