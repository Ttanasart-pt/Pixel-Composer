//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float seed;
uniform float strength;
uniform float dist;
uniform int useMap;
uniform sampler2D strengthMap;

uniform int gradient_blend;
uniform vec4 gradient_color[16];
uniform float gradient_time[16];
uniform int gradient_keys;

uniform float alpha_curve[4];

vec4 gradientEval(in float prog) {
	vec4 col = vec4(0.);
	
	for(int i = 0; i < 16; i++) {
		if(gradient_time[i] == prog) {
			col = gradient_color[i];
			break;
		} else if(gradient_time[i] > prog) {
			if(i == 0) 
				col = gradient_color[i];
			else {
				if(gradient_blend == 0)
					col = mix(gradient_color[i - 1], gradient_color[i], (prog - gradient_time[i - 1]) / (gradient_time[i] - gradient_time[i - 1]));
				else if(gradient_blend == 1)
					col = gradient_color[i - 1];
			}
			break;
		}
		if(i >= gradient_keys - 1) {
			col = gradient_color[gradient_keys - 1];
			break;
		}
	}
	
	return col;
}

float curveEval(in float curve[4], in float prog) {
	return pow(1. - prog, 3.) * curve[0] + 
		3. * pow(1. - prog, 2.) * prog * curve[1] + 
		3. * (1. - prog) * pow(prog, 2.) * curve[2] + 
		pow(prog, 3.) * curve[3];	
}

float frandom (in vec2 st, in float _seed) {
	float f = fract(sin(dot(st.xy, vec2(12.9898, 78.233)) * mod(15.15 + seed, 32.156 + _seed) * 12.588) * 43758.5453123);
	f = f * 2. - 1.;
    return f;
}

vec2 vrandom (in vec2 st) {
    return vec2(frandom(st, 165.84), frandom(st, 98.01));
}

void main() {
	vec2 _pos = v_vTexcoord;
	float str = strength;
	
	vec2 _vec = vrandom(_pos) * str * dist;
	
	if(useMap == 1) {
		vec4 _map = texture2D( strengthMap, _pos);
		_vec.x *= _map.r;
		_vec.y *= _map.g;
		str *= dot(_map.rg, _map.rg);
	}
	
	str += frandom(_pos, 12.01) * abs(.1) * str;
	
	vec2 _new_pos = _pos - _vec;
	vec4 _col;
	
	if(_new_pos == clamp(_new_pos, 0., 1.)) {
		_col = texture2D( gm_BaseTexture, _pos - _vec );
		_col.rgb *= gradientEval(str).rgb;
		_col.a *= curveEval(alpha_curve, str);
	} else {
		_col = vec4(0.);	
	}
	
    gl_FragColor = _col;
}

