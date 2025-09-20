varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D surface_1;
uniform sampler2D depth_1;
uniform sampler2D surface_2;
uniform sampler2D depth_2;

void main() {
	vec4  s1 = texture2D(surface_1, v_vTexcoord);
	vec4  D1 = texture2D(depth_1,   v_vTexcoord);
	float d1 = (D1.x + D1.y + D1.z) / 3. * D1.a;
	
	vec4  s2 = texture2D(surface_2, v_vTexcoord);
	vec4  D2 = texture2D(depth_2,   v_vTexcoord);
	float d2 = (D2.x + D2.y + D2.z) / 3. * D2.a;
	
	gl_FragData[0] = d1 < d2? s1 : s2;
	gl_FragData[1] = vec4(vec3(min(d1, d2)), 1.);
}