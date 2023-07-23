//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
    gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
	if(gl_FragColor.a == 0.) 
		gl_FragColor = vec4(0.);
	else 
		gl_FragColor = vec4(1.);
}
