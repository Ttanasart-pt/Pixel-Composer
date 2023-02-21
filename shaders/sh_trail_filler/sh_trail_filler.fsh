//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define TAU 6.283185307179586

uniform sampler2D prevFrame;
uniform vec2 dimension;
uniform float range;

void main() {
    vec4 colCur = texture2D( gm_BaseTexture, v_vTexcoord );
	
	if(colCur.a > 0.5) {
		gl_FragColor = colCur;
		return;
	}
	
	gl_FragColor = vec4(0.);
	float aStep = TAU / 64.;
	vec2 texel = 1. / dimension;
	
	for(float i = 1.; i <= range; i++)
	for(float j = 0.; j <= TAU; j += aStep) {
		vec2 shift = vec2(cos(j), sin(j)) * i * texel;
		vec2 pos0 = v_vTexcoord + shift;
		
		if(pos0.x < 0. || pos0.y < 0. || pos0.x > 1. || pos0.y > 1.) continue;
		vec4 col0 = texture2D( prevFrame, pos0 );
		if(col0.a <= 0.5) continue;
		
		vec2 norm = normalize(shift) * texel;
		for(float k = 1.; k <= range; k++) {
			vec2 posS = v_vTexcoord - norm * k;
			if(posS.x < 0. || posS.y < 0. || posS.x > 1. || posS.y > 1.) continue;
			
			vec4 colS = texture2D( gm_BaseTexture, posS );
			if(colS.a <= 0.5) continue;
			
			gl_FragColor = colS;
			return;
		}
	}
}
