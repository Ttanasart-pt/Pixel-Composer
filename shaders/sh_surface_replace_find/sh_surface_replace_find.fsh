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

vec2 baseTx = 1. / dimension;
vec2 targTx = 1. / target_dim;

float matchTemplate(vec2 pos) {	
	float _match = 0.;
	float content_px = 0.;
	
	for( float i = 0.; i < target_dim.x; i++ ) 
	for( float j = 0.; j < target_dim.y; j++ ) {
		vec4 targ = texture2D( target, vec2(i, j) * targTx );
		if(targ.a == 0.) continue;
		
		vec2 bpx  = pos + vec2(i, j);
		vec4 base = texture2D( gm_BaseTexture, bpx * baseTx );
		
		content_px++;
		if(distance(base, targ) <= 2. * colorThreshold)
			_match++;
	}
	
	return _match / content_px;
}

void main() {
	vec4 base = texture2D( gm_BaseTexture, v_vTexcoord );
	if(base.a == 0.) {
		gl_FragColor = vec4(vec3(0.), 0.);
		return;
	}
	
	vec2 px = v_vTexcoord * dimension;
	
	float match = 0.;
	vec2  matchPos = vec2(0., 0.);
	vec2  matchUv  = vec2(0., 0.);
	
	for( float i = 0.; i < target_dim.x; i++ ) 
	for( float j = 0.; j < target_dim.y; j++ ) {
		vec2 uv = px - vec2(i, j);
		if(uv.x < 0. || uv.y < 0.) continue;
		if(uv.x + target_dim.x > dimension.x || uv.y + target_dim.y > dimension.y) continue;
		
		float matchTemp = matchTemplate(uv);
		if(matchTemp > match) {
			match    = matchTemp;
			matchPos = vec2(i, j) / (target_dim - 1.);
			matchUv  = uv / dimension;
		}
	}
	
	float ind = mode == 0? index : round(random(matchUv) * (size - 1.)) / size;
    gl_FragColor = match > (1. - pixelThreshold - 1. / (target_dim.x * target_dim.y))? vec4(matchPos, ind, 1.) : vec4(0.);
}