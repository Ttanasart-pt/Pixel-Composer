//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform sampler2D target;
uniform vec2 target_dim;
uniform float threshold;
uniform float index;

void main() {
	vec4 base = texture2D( gm_BaseTexture, v_vTexcoord );
	if(base.a == 0.) {
		gl_FragColor = vec4(0.);
		return;
	}
	
	vec2 px = v_vTexcoord * dimension;
	float pixels_count  = target_dim.x * target_dim.y;
	float target_pixels = pixels_count * (1. - threshold);
	float match = 0.;
	vec2 baseTx = 1. / dimension;
	vec2 targTx = 1. / target_dim;
	
	gl_FragColor = vec4(0.);
	
	for( float i = 0.; i < target_dim.x; i++ ) 
	for( float j = 0.; j < target_dim.y; j++ ) {
		vec2 bpx  = px + vec2(i, j);
		vec4 base = texture2D( gm_BaseTexture, bpx * baseTx );
		vec4 targ = texture2D( target, vec2(i, j) * targTx );
		
		if(distance(base.rgb * base.a, targ.rgb * targ.a) <= threshold) {
			match++;
			if(match >= target_pixels) {
				gl_FragColor = vec4(1., index, 0., 1.);
				return;
			}
		}
	}
	
	//gl_FragColor = vec4(match / pixels_count, index, 0., 1.);
}
