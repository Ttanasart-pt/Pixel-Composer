//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define PI 3.14159265359

uniform vec2 dimension;
uniform vec2 position;
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
	//return mod(floor(_x / _a) + floor(_y / _a), 2.);
}

void main() {
	
		float amo = amount.x;
		if(amountUseSurf == 1) {
			vec4 _vMap = texture2D( amountSurf, v_vTexcoord );
			amo = mix(amount.x, amount.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float ang = angle.x;
		if(angleUseSurf == 1) {
			vec4 _vMap = texture2D( angleSurf, v_vTexcoord );
			ang = mix(angle.x, angle.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		ang = radians(ang);
	
	
	vec2 a = dimension / dimension.y;
	vec2 c = (v_vTexcoord - position) * a;
	
	float ch = check(c, amo, ang);
	
	if(blend == 0) gl_FragColor = ch < 0.5? col1 : col2;
	else if(blend == 1) { 
		gl_FragColor = mix(col1, col2, ch);
			
	} else if(blend == 2) { 
		float px = 2. / max(dimension.x, dimension.y);
		ch = smoothstep(0.5 - px, 0.5 + px, ch);
			
		gl_FragColor = mix(col1, col2, ch);
	}
}

