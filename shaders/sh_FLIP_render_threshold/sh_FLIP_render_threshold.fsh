//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 fluid = texture2D( gm_BaseTexture, v_vTexcoord );
    gl_FragColor = vec4(0.);
	
	if(fluid.r * fluid.a > 0.5)	
		gl_FragColor = vec4(1.);
}
