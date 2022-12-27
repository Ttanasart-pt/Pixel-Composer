//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D map;
uniform vec2  dimension;
uniform vec2  map_dimension;
uniform vec2  displace;
uniform float strength;
uniform float middle;
uniform int iterate;
uniform int use_rg;
uniform int sampleMode;

#define PI 3.14159265359

float bright(in vec4 col) {
	return dot(col.rgb, vec3(0.2126, 0.7152, 0.0722))  * col.a;
}

vec4 sampleTexture(vec2 pos) {
	if(pos.x > 0. && pos.y > 0. && pos.x < 1. && pos.y < 1.)
		return texture2D(gm_BaseTexture, pos);
	
	if(sampleMode == 0) 
		return vec4(0.);
	if(sampleMode == 1) 
		return texture2D(gm_BaseTexture, clamp(pos, 0., 1.));
	if(sampleMode == 2) 
		return texture2D(gm_BaseTexture, fract(pos));
	
	return vec4(0.);
}

vec2 shiftMap(in vec2 pos, in float str) {
	vec4 disP = texture2D( map, pos );
	vec2 sam_pos;
	vec2 raw_displace = displace / dimension;
	float _str;
	
	if(use_rg == 1) {
		vec2 _disp = vec2(disP.r - middle, disP.g - middle) * vec2((disP.r + disP.g + disP.b) / 3. - middle) * str;
		
		sam_pos = pos + _disp;
	} else if(use_rg == 2) {
		float _ang = disP.r * PI * 2.;
		_str = (disP.g - middle) * str;
		
		sam_pos = pos + _str * vec2(cos(_ang), sin(_ang));
	} else {
		_str = (bright(disP) - middle) * str;
		
		sam_pos = pos + _str * raw_displace;
	}
	
	return sam_pos;
}

void main() {
	vec2 samPos = v_vTexcoord;
	
	if(iterate == 1) {
		for(float i = 0.; i < strength; i++) {
			samPos = shiftMap(samPos, 1.);
		}
	} else
		samPos = shiftMap(samPos, strength);
	
	vec4 col = sampleTexture( samPos );
	
    gl_FragColor = col;
}
