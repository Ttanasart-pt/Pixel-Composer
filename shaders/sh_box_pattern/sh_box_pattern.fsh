varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define PI 3.14159265359

uniform vec2 dimension;
uniform vec2 position;
uniform int  blend;
uniform int  pattern;
uniform int  iteration;

uniform vec2      amount;
uniform int       amountUseSurf;
uniform sampler2D amountSurf;

uniform vec2      angle;
uniform int       angleUseSurf;
uniform sampler2D angleSurf;

uniform vec2      width;
uniform int       widthUseSurf;
uniform sampler2D widthSurf;

uniform vec4 col1;
uniform vec4 col2;

float pat_cross(vec2 p, float w) {
    vec2 f = fract(abs(p));
    vec2 c = abs(f - 0.5);
    float sx, sy, m;
    
	if(blend == 0) { 
		sx = step(w / 2., c.x);
	    sy = step(w / 2., c.y);
	    
	    m = mod(sx + sy, 2.);
		return m; 
		
    } else if(blend == 1) { 
		sx = abs(w / 2. - c.x);
	    sy = abs(w / 2. - c.y);
	    
	    m = mod(sx + sy, 2.);
		return m;
		
    } else if(blend == 2) { 
    	float d = 1. / max(dimension.x, dimension.y);
		sx = smoothstep(w / 2. - d, w / 2. + d, c.x);
	    sy = smoothstep(w / 2. - d, w / 2. + d, c.y);
	    
	    m = mod(sx + sy, 2.);
		return m;
    }
    
    return 0.;
}

float pat_xor( vec2 p, int itr ) {
    float res = 0.0;
    
    for( int i = 0; i < itr; i++ ) {
        res += mod( floor(p.x) + floor(p.y), 2.0 );
        p *= 0.5;
        res *= 0.5;
    }
    
    return res;
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
		
		float wid = width.x;
		if(widthUseSurf == 1) {
			vec4 _vMap = texture2D( widthSurf, v_vTexcoord );
			wid = mix(width.x, width.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
	#endregion
	
	vec2 a = dimension / dimension.y;
	vec2 c = (v_vTexcoord - position) * a;
	c *= mat2(cos(ang), -sin(ang), sin(ang), cos(ang));
	c *= amo;
	
	if(pattern == 0) {
		float ch = pat_cross(c, wid);
		gl_FragColor = mix(col1, col2, ch);
		
	} else if(pattern == 1) {
		float ch = pat_xor(c, iteration);
		gl_FragColor = mix(col1, col2, ch);
		
	}
}
