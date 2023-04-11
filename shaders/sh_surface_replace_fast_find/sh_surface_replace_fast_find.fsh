//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform sampler2D target;
uniform vec2 target_dim;
uniform float colorThreshold;
uniform float pixelThreshold;
uniform float index;

uniform int mode;
uniform float seed;
uniform float size;

float random (in vec2 st) { return fract(sin(dot(st.xy + seed, vec2(12.9898, 78.233))) * 43758.5453123); }
float round(float val) { return fract(val) > 0.5? ceil(val) : floor(val); }

void main() {
	vec4 base = texture2D( gm_BaseTexture, v_vTexcoord );
	if(base.a == 0.) {
		gl_FragColor = vec4(0.);
		return;
	}
	
	vec2 px = v_vTexcoord * dimension;
	float pixels_count  = target_dim.x * target_dim.y;
	float target_pixels = pixels_count * (1. - pixelThreshold);
	float content_px    = 0.;
	float match = 0.;
	vec2 baseTx = 1. / dimension;
	vec2 targTx = 1. / target_dim;
	
	gl_FragColor = vec4(0.);
	
	for( float i = 0.; i < target_dim.x; i++ ) 
	for( float j = 0.; j < target_dim.y; j++ ) {
		vec4 targ = texture2D( target, vec2(i, j) * targTx );
		if(targ.a == 0.) continue;
		
		vec2 bpx  = px + vec2(i, j);
		vec4 base = texture2D( gm_BaseTexture, bpx * baseTx );
		
		content_px++;
		if(distance(base, targ) <= 2. * colorThreshold) {
			match++;
			if(match >= target_pixels) {
				gl_FragColor = vec4(1., index, 0., 1.);
				return;
			}
		}
	}
	
	if(match / content_px >= (1. - pixelThreshold)) {
		float ind = mode == 0? index : round(random(v_vTexcoord) * (size - 1.)) / size;
		gl_FragColor = vec4(1., ind, 0., 1.);
	}
}
