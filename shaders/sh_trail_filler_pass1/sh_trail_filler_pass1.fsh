//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define TAU 6.283185307179586

uniform sampler2D prevFrame;
uniform vec2 dimension;
uniform float range;
uniform float segmentStart;
uniform float segmentSize;

uniform int mode;
uniform int matchColor;
uniform int blendColor;

void main() {
	gl_FragColor = vec4(0.);
	
    vec4 colCur = texture2D( gm_BaseTexture, v_vTexcoord );
	if(colCur.a > 0.5) {
		if(mode == 0) gl_FragColor = colCur;
		return;
	}
	
	float colThres = 0.02;
	vec2 texel = 1. / dimension;
	
	for(float i = 0.; i <= range; i++) {
		float base = 1.;
		float top  = 0.;
		for(float j = 0.; j <= 64.; j++) {
			float ang = top / base * TAU;
			top += 2.;
			if(top >= base) {
				top = 1.;
				base *= 2.;
			}
		
			vec2 shift = vec2(cos(ang), sin(ang)) * i * texel;
			vec2 pos0 = v_vTexcoord + shift;
		
			if(pos0.x < 0. || pos0.y < 0. || pos0.x > 1. || pos0.y > 1.) continue;
			vec4 col0 = texture2D( gm_BaseTexture, pos0 );
			if(col0.a <= 0.5) continue;
		
			vec2 norm = normalize(shift) * texel;
			vec4 _colS = vec4(0.);
			int searchStage = 0;
			
			for(float k = 0.; k <= range; k++) {
				vec2 posS = v_vTexcoord - norm * k;
				if(searchStage == 0 && (posS.x < 0. || posS.y < 0. || posS.x > 1. || posS.y > 1.)) continue;
			
				vec4 colS = texture2D( prevFrame, posS );
				if(mode == 0 && matchColor == 1) {
					if(matchColor == 1 && distance(colS, col0) >= colThres) continue;
					gl_FragColor = col0;
					return;
				} else {
					if(searchStage == 0 && ((matchColor == 0 && colS.a > 0.5) || (matchColor == 1 && distance(colS, col0) <= colThres))) {
						searchStage = 1;
						_colS = colS;
						gl_FragColor = col0;
					} else if(searchStage == 1 && ((matchColor == 0 && colS.a < 0.5) || (matchColor == 1 && distance(colS, col0) >= colThres))) {
						if(matchColor == 0)
							gl_FragColor = mix(_colS, col0, blendColor == 0? 1. : 1. - i / k);
						else
							gl_FragColor = vec4(norm.x, norm.y, segmentStart + segmentSize * (i / k), 1.);
						return;
					}
				}
			}
		}
	}
}
