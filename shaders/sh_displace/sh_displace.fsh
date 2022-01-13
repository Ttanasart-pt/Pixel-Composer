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
uniform int   iterate;
uniform int   use_rg;
uniform int   wrap;

#define PI 3.14159265359

float bright(in vec4 col) {
	return dot(col.rgb, vec3(0.2126, 0.7152, 0.0722))  * col.a;
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
	
	if(wrap == 0)
		return sam_pos;
	return fract(sam_pos);
}

void main() {
	vec2 samPos = v_vTexcoord;
	
	if(iterate == 1) {
		for(float i = 0.; i < strength; i++) {
			samPos = shiftMap(samPos, 1.);
		}
	} else {
		samPos = shiftMap(samPos, strength);
	}
	
	samPos.x = clamp(samPos.x, 0., 1.);
	samPos.y = clamp(samPos.y, 0., 1.);
	
	vec4 col = v_vColour * texture2D( gm_BaseTexture, samPos );
	
    gl_FragColor = col;
}
