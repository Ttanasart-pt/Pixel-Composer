#pragma use(uv)

#region -- uv -- [1770002023.9166503]
    uniform sampler2D uvMap;
    uniform int   useUvMap;
    uniform float uvMapMix;

    vec2 getUV(in vec2 uv) {
        if(useUvMap == 0) return uv;

        vec2 vuv   = texture2D( uvMap, uv ).xy;
             vuv.y = 1.0 - vuv.y;

        vec2 vtx = mix(uv, vuv, uvMapMix);
        return vtx;
    }
#endregion -- uv --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define PI 3.14159265359

uniform vec2 dimension;
uniform vec2 position;
uniform int  diagonal;
uniform int  blend;

uniform vec2      amount;
uniform int       amountUseSurf;
uniform sampler2D amountSurf;

uniform vec2      angle;
uniform int       angleUseSurf;
uniform sampler2D angleSurf;

uniform vec4 col1;
uniform vec4 col2;

float check(vec2 c, float amo, float ang) {
	float _x = c.x * cos(ang) - c.y * sin(ang);
	float _y = c.x * sin(ang) + c.y * cos(ang);
	float _a = 1. / amo;
	
	vec2  px = vec2(floor(_x / _a) + 0.5, floor(_y / _a) + 0.5) * _a;
	float dd = 1. - (max(abs(px.x - _x), abs(px.y - _y)) / _a + 0.5);
	float mm = mod(floor(_x / _a) + floor(_y / _a), 2.);
	
	return mm < .5? 0.5 + dd : 0.5 - dd;
}

void main() {
	#region params
		float amo = amount.x;
		if(amountUseSurf == 1) {
			vec4 _vMap = texture2D( amountSurf, v_vTexcoord );
			amo = mix(amount.x, amount.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		amo = dimension.x / amo;
		
		float ang = angle.x;
		if(angleUseSurf == 1) {
			vec4 _vMap = texture2D( angleSurf, v_vTexcoord );
			ang = mix(angle.x, angle.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		ang = radians(ang);
	#endregion
	
	vec2 vtx = getUV(v_vTexcoord);
	vec2 a   = dimension / dimension.y;
	vec2 c   = (vtx - position) * a;
	float ch;
	
	if(diagonal == 0 || blend != 0) {
		if(diagonal == 1) {
			ang += PI / 4.;
			amo *= sqrt(2.);
		}
		
		ch = check(c, amo, ang);
		
	} else {
		vec2 pa = floor(dimension / amo);
		vec2 px = floor(dimension * c);
		     px = mod(px, pa);
		
		bool d1 = px.x > px.y;
		bool d2 = (pa.x - px.x) > px.y;
		bool chk = (d1 && d2) || (!d1 && !d2);
		
		ch = chk? 1. : 0.;
	}
	
	
	if(blend == 0) gl_FragColor = ch < 0.5? col1 : col2;
	else if(blend == 1) { 
		gl_FragColor = mix(col1, col2, ch);
			
	} else if(blend == 2) { 
		float px = 2. / max(dimension.x, dimension.y);
		ch = smoothstep(0.5 - px, 0.5 + px, ch);
			
		gl_FragColor = mix(col1, col2, ch);
	}
}
