varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define PI 3.14159265359

uniform vec2  dimension;
uniform vec2  position;

uniform vec2      amount;
uniform int       amountUseSurf;
uniform sampler2D amountSurf;

uniform vec2      angle;
uniform int       angleUseSurf;
uniform sampler2D angleSurf;

uniform vec2      phase;
uniform int       phaseUseSurf;
uniform sampler2D phaseSurf;

uniform vec2      rangleRange;

uniform vec4  color0;
uniform vec4  color1;

uniform sampler2D uvMap;
uniform int   useUvMap;
uniform float uvMapMix;

void main() {
	#region params
		float amo = amount.x;
		if(amountUseSurf == 1) {
			vec4 _vMap = texture2D( amountSurf, v_vTexcoord );
			amo = mix(amount.x, amount.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		amo = dimension.x / amo * 2.;
		
		float ang = angle.x;
		if(angleUseSurf == 1) {
			vec4 _vMap = texture2D( angleSurf, v_vTexcoord );
			ang = mix(angle.x, angle.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		ang = radians(ang);
		
		float pha = phase.x;
		if(phaseUseSurf == 1) {
			vec4 _vMap = texture2D( phaseSurf, v_vTexcoord );
			pha = mix(phase.x, phase.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
	#endregion
	
	vec2 vtx = useUvMap == 0? v_vTexcoord : mix(v_vTexcoord, texture2D( uvMap, v_vTexcoord ).xy, uvMapMix);
	vec2 ntx = vtx * vec2(1., dimension.y / dimension.x);
	vec2 pos = (ntx - position) * mat2(cos(ang), -sin(ang), sin(ang), cos(ang)) * amo;
	
    float value = 0.0;
    int   num = 4;
	
	float as = radians(rangleRange.x);
	float an = radians(rangleRange.y);
	
    for(int i = 0; i < num; i++) {
    	float a = mix(as, an, float(i) / float(num));
    	float w = pos.x * sin(a) + pos.y * cos(a);
		
		value += sin(w + pha * PI * 2.);
    }
	
    float _s = 1. + sin(value * PI / 2.0);
	gl_FragColor = mix(color0, color1, _s); 
} 
