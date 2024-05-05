//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

uniform sampler2D target;
uniform vec2 targetDimension;

uniform float colorThreshold;
uniform float pixelThreshold;
uniform float index;

uniform int mode;
uniform float seed;
uniform float size;

float random (in vec2 st) { return fract(sin(dot(st.xy + seed, vec2(12.9898, 78.233))) * 43758.5453123); }
float round(float val) { return fract(val) > 0.5? ceil(val) : floor(val); }

vec2 baseTx = 1. / dimension;
vec2 targTx = 1. / targetDimension;

float matchTemplate(vec2 pos) {	
	float _match = 0.;
	
	for( float i = 0.; i < targetDimension.x; i++ ) 
	for( float j = 0.; j < targetDimension.y; j++ ) {
		vec4 targ = texture2D( target, vec2(0.5 + i, 0.5 + j) * targTx );
		
		vec2 bpx  = pos + vec2(i, j);
		vec4 base = texture2D( gm_BaseTexture, bpx * baseTx );
		
		if(distance(base, targ) <= 2. * colorThreshold)
			_match++;
	}
	
	return _match / (targetDimension.x * targetDimension.y);
}

void main() {
	gl_FragColor = vec4(0.);
	
	vec4 base = texture2D( gm_BaseTexture, v_vTexcoord );
	
	vec2 px = v_vTexcoord * dimension;
	
	float match = 0.;
	vec2  matchPos = vec2(0., 0.);
	vec2  matchUv  = vec2(0., 0.);
	
	for( float i = 0.; i < targetDimension.x; i++ ) 
	for( float j = 0.; j < targetDimension.y; j++ ) {
		vec2 uv = px - vec2(i, j);
		if(uv.x < 0. || uv.y < 0.) continue;
		if(uv.x - .5 + targetDimension.x > dimension.x || uv.y - .5 + targetDimension.y > dimension.y) continue;
		
		gl_FragColor = vec4(1.);
		float matchTemp = matchTemplate(uv);
		if(matchTemp > match) {
			match    = matchTemp;
			matchPos = (vec2(i, j) + 0.5) * targTx;
			matchUv  = uv * baseTx;
		}
	}
	
	if(match >= 1. - pixelThreshold) {
		float ind = mode == 0? index : round(random(matchUv) * (size - 1.)) / size;
		gl_FragColor = vec4(matchPos, ind, 1.);
	}
}
