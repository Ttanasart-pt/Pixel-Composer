//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float threshold;

void main() {
	vec4 fluid = texture2D( gm_BaseTexture, v_vTexcoord );
    gl_FragColor = vec4(0.);
	
	if(fluid.a > threshold)	
		gl_FragColor = vec4(fluid.rgb, 1.);
}
