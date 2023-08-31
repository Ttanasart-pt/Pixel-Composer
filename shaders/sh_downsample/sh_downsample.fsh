//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float down;
uniform vec2 dimension;

void main() {
	vec4 col  = vec4(0.);
	float wei = 0.;
	
	for( float i = 0.; i < down; i++ ) 
	for( float j = 0.; j < down; j++ ) {
		vec4 samp = texture2D( gm_BaseTexture, v_vTexcoord * down + vec2(i, j) / dimension );
		col += samp;
		wei += samp.a;
	}
	
	col /= wei;	
	
    gl_FragColor = col * v_vColour;
}
