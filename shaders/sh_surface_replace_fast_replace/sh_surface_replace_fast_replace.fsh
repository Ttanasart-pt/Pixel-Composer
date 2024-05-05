//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform sampler2D replace;
uniform vec2 replace_dim;
uniform sampler2D findRes;
uniform float index;

void main() {
	gl_FragColor = vec4(0.);
	
	vec2 px = v_vTexcoord * dimension - (replace_dim - 1.);
	
	for( float i = 0.; i < replace_dim.x; i++ ) 
	for( float j = 0.; j < replace_dim.y; j++ ) {
		vec2 uv = px + vec2(i, j);
		if(uv.x < 0. || uv.y < 0.) continue;
		
		vec4 wg = texture2D( findRes, uv / dimension );
		
		if(wg.r == 1. && abs(wg.g - index) < 0.01) {
			gl_FragColor = texture2D( replace, (replace_dim - vec2(i, j) - 1. + .5) / replace_dim );
			return;
		}
	}
}
