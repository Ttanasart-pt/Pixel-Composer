//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define PI 3.14159265359

uniform sampler2D prevFrame;
uniform vec2 dimension;
uniform float range;

void main() {
    vec4 colCur = texture2D( gm_BaseTexture, v_vTexcoord );
    vec4 colPre = texture2D( prevFrame, v_vTexcoord );
	
	if(colCur.a > 0.) {
		gl_FragColor = colCur;
		return;
	}
	
	gl_FragColor = vec4(0.);
	float piStep = PI / 64.;
	
	for(float i = 0.; i <= range; i++)
	for(float j = 0.; j <= PI * 2.; j += piStep) {
		vec2 shift = vec2(cos(j), sin(j)) * i / dimension;
		vec2 pos0 = v_vTexcoord + shift;
		vec2 pos1 = v_vTexcoord - shift;
		
		if(pos0.x < 0. || pos0.y < 0. || pos0.x > 1. || pos0.y > 1.) continue;
		vec4 col0 = texture2D( prevFrame, pos0 );
		if(col0.a == 0.) continue;
		
		vec2 norm = normalize(shift);
		
		for(float k = 0.; k <= range; k++) {
			vec2 posS = v_vTexcoord - norm * k / dimension;
			if(posS.x < 0. || posS.y < 0. || posS.x > 1. || posS.y > 1.) continue;
			
			vec4 colS = texture2D( gm_BaseTexture, posS );
			if(colS.a == 0.) continue;
			
			gl_FragColor = colS;
			return;
		}
	}
}
