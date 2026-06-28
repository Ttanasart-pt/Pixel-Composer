varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

uniform sampler2D surface_1;
uniform sampler2D depth_1;
uniform int  surface_1_use;
uniform int  use_depth_1;
uniform vec2 range_1;

uniform vec2  position_1;
uniform vec2  anchor_1;
uniform float rotation_1;
uniform vec2  scale_1;

uniform sampler2D surface_2;
uniform sampler2D depth_2;
uniform int  surface_2_use;
uniform int  use_depth_2;
uniform vec2 range_2;

uniform vec2  position_2;
uniform vec2  anchor_2;
uniform float rotation_2;
uniform vec2  scale_2;

void main() {
	mat2 rot1 = mat2(cos(rotation_1), sin(rotation_1), -sin(rotation_1), cos(rotation_1));
	vec2 tx1  = (v_vTexcoord - anchor_1) * rot1 / scale_1 + anchor_1 - position_1 / dimension;
	
	vec4  s1 = texture2D(surface_1, tx1);
	float d1;
	
	if(use_depth_1 == 1) {
		vec4 D1 = texture2D(depth_1, tx1);
		d1 = (D1.x + D1.y + D1.z) / 3. * D1.a;
		d1 = mix(range_1.x, range_1.y, d1);
		
	} else
		d1 = mix(range_1.x, range_1.y, tx1.y);
	
	gl_FragData[0] = s1;
	gl_FragData[1] = vec4(vec3(d1), 1.);
	
	if(surface_2_use == 0) return;
	
	mat2 rot2 = mat2(cos(rotation_2), sin(rotation_2), -sin(rotation_2), cos(rotation_2));
	vec2 tx2  = (v_vTexcoord - anchor_2) * rot2 / scale_2 + anchor_2 - position_2 / dimension;
	
	vec4  s2 = texture2D(surface_2, tx2);
	float d2;
	
	if(use_depth_2 == 1) {
		vec4 D2 = texture2D(depth_2, tx2);
		d2 = (D2.x + D2.y + D2.z) / 3. * D2.a;
		d2 = mix(range_2.x, range_2.y, d2);
		      
	} else
		d2 = mix(range_2.x, range_2.y, tx2.y);
	
	if(s2.a == 0.) return;
	
	vec4 bg = d1 >= d2? s1 : s2;
	vec4 fg = d1 <  d2? s1 : s2;
	
	gl_FragData[0] = bg * (1. - fg.a) + fg * fg.a;
	gl_FragData[1] = vec4(vec3(min(d1, d2)), 1.);
}