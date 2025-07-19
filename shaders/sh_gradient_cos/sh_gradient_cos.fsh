// Created by inigo quilez

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 center;
uniform vec2 dimension;

uniform float angle;
uniform float radius;
uniform float shift;
uniform float scale;

uniform int type;
uniform int uniAsp;

uniform vec2 cirScale;

uniform vec3 co_a;
uniform vec3 co_a_max;
uniform int  co_a_use;
uniform sampler2D co_a_map;

uniform vec3 co_b;
uniform vec3 co_b_max;
uniform int  co_b_use;
uniform sampler2D co_b_map;

uniform vec3 co_c;
uniform vec3 co_c_max;
uniform int  co_c_use;
uniform sampler2D co_c_map;

uniform vec3 co_d;
uniform vec3 co_d_max;
uniform int  co_d_use;
uniform sampler2D co_d_map;

#define TAU 6.283185307179586

vec3 pal( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d ) {
    return a + b * cos( 6.28318 * (c * t + d) );
}

float sLength(vec2 p) { return max(abs(p.x), abs(p.y)); }
float dLength(vec2 p) { return (abs(p.x) + abs(p.y));   }

void main() {
	#region params
		vec3 _a = co_a;
		if(co_a_use == 1) {
			vec4 _vMap = texture2D( co_a_map, v_vTexcoord );
			_a = mix(co_a, co_a_max, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		vec3 _b = co_b;
		if(co_b_use == 1) {
			vec4 _vMap = texture2D( co_b_map, v_vTexcoord );
			_b = mix(co_b, co_a_max, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		vec3 _c = co_c;
		if(co_c_use == 1) {
			vec4 _vMap = texture2D( co_c_map, v_vTexcoord );
			_c = mix(co_c, co_a_max, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		vec3 _d = co_d;
		if(co_d_use == 1) {
			vec4 _vMap = texture2D( co_d_map, v_vTexcoord );
			_d = mix(co_d, co_a_max, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float ang = radians(angle);
		float rad = radius * sqrt(2.);
		float shf = shift;
		float sca = scale;
	#endregion
	
	
	vec2  asp  = dimension / dimension.y;
	vec2  cent = center / dimension;
	float prog = 0.;
	mat2  rot  = mat2(cos(ang), - sin(ang), sin(ang), cos(ang));
	
	if(type == 0) { // linear
		prog = .5 + (v_vTexcoord.x - cent.x) * cos(ang) - (v_vTexcoord.y - cent.y) * sin(ang);
		
	} else if(type == 1) { // circular
		vec2 _asp = uniAsp == 0? vec2(1.) : asp;
		prog = length((v_vTexcoord - cent) * _asp / cirScale) / rad;
		
	} else if(type == 2) { // radial
		vec2  _p = v_vTexcoord - cent;
		if(uniAsp == 1) _p *= asp;
		
		float _a = atan(_p.y, _p.x) + ang;
		prog = (_a - floor(_a / TAU) * TAU) / TAU;
		
	} else if(type == 3) { // diamond
		vec2 _asp = uniAsp == 0? vec2(1.) : asp;
		prog = dLength((v_vTexcoord - cent) * rot * _asp / cirScale) / rad;
		
	} 
	
	prog = (prog + shf - 0.5) / sca + 0.5;
	
	vec3 col = pal(prog, _a, _b, _c, _d);
	gl_FragColor = vec4(col, 1.);
}