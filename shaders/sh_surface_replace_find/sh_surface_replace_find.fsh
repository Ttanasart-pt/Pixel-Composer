//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform sampler2D target;
uniform vec2 target_dim;
uniform float threshold;

float random (in vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float matchTemplate(vec2 pos) {	
	float match = 0.;
	vec2 baseTx = 1. / dimension;
	vec2 targTx = 1. / target_dim;
	
	for( float i = 0.; i < target_dim.x; i++ ) 
	for( float j = 0.; j < target_dim.y; j++ ) {
		vec2 bpx  = pos + vec2(i, j);
		vec4 base = texture2D( gm_BaseTexture, bpx * baseTx );
		vec4 targ = texture2D( target, vec2(i, j) * targTx );
		
		if(distance(base.rgb * base.a, targ.rgb * targ.a) <= threshold)
			match++;
	}
	
	return match;
}

void main() {
	vec4 base = texture2D( gm_BaseTexture, v_vTexcoord );
	if(base.a == 0.) {
		gl_FragColor = vec4(vec3(0.), 0.);
		return;
	}
	
	vec2 px = v_vTexcoord * dimension;
	
	float target_pixels = target_dim.x * target_dim.y * (1. - threshold);
	float match = 0.;
	vec2  matchPos = vec2(0., 0.);
	
	for( float i = 0.; i < target_dim.x; i++ ) 
	for( float j = 0.; j < target_dim.y; j++ ) {
		vec2 uv = px - vec2(i, j);
		if(uv.x < 0. || uv.y < 0.) continue;
		if(uv.x + target_dim.x > dimension.x || uv.y + target_dim.y > dimension.y) continue;
		
		float matchTemp = matchTemplate(uv);
		if(matchTemp > match) {
			match    = matchTemp;
			matchPos = vec2(i, j) / target_dim;
		}
	}
	
    gl_FragColor = match >= target_pixels? vec4(matchPos, random(matchPos), 1.) : vec4(vec3(0.), 0.);
}
