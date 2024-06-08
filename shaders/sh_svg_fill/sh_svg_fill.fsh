varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D bg, fg;

void main() {
    vec4 _bc = texture2D(bg, v_vTexcoord);
    vec4 _fc = texture2D(fg, v_vTexcoord);
    
    // gl_FragColor = _fc; return;
    
    gl_FragColor = _bc;
    if(_fc.a == 0.) return;
    
    gl_FragColor = _bc.a == 0.? v_vColour : vec4(0.);
}
