#define TAU 6.28318530718

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float threshold;

uniform vec2      radius;
uniform int       radiusUseSurf;
uniform sampler2D radiusSurf;

void main() {
	float rad    = radius.x;
	float radMax = max(radius.x, radius.y);
	if(radiusUseSurf == 1) {
		vec4 _vMap = texture2D( radiusSurf, v_vTexcoord );
		rad = mix(radius.x, radius.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec2 tx = 1. / dimension;
	vec4 cc = vec4(0.);
	float av = 0., dv = 0.;
	
	float stp = TAU / 64.;
	
	for(float i = 0.; i < radMax; i++) {
		if(i > rad) break;
		
		for(float j = 0.; j < TAU; j += stp) {
			vec2 sx = v_vTexcoord + vec2(cos(j), sin(j)) * tx * i;
			
			vec4 c = texture2D( gm_BaseTexture, sx );
			
			cc += c;
			dv += 1.;
			av += c.a;
		}
	}
	
	cc /= dv;
	
    gl_FragColor = step(threshold, cc);
}
