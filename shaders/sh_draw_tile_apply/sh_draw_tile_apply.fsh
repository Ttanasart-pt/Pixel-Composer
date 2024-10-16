varying vec2 v_vTexcoord;
varying vec4 v_vColour;

// uniform sampler2D canvas;
// uniform sampler2D drawing;

void main() {
    gl_FragColor = vec4(0.);
    // vec4 c = texture2D( canvas,  v_vTexcoord );
    // vec4 d = texture2D( drawing, v_vTexcoord );
    
    // gl_FragColor = d.r > 0.? d : c;
}
