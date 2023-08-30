varying vec2 v_vTexcoord;
varying vec4 v_worldPosition;
varying vec3 v_viewPosition;
varying vec3 v_vNormal;

uniform int			use_normal;
uniform float		normal_strength;
uniform sampler2D	normal_map;

void main() {
	gl_FragData[0] = vec4(v_worldPosition.xyz, 1.);
	gl_FragData[1] = vec4(v_viewPosition, 1.);
	
	vec3 normal = v_vNormal;
	if(use_normal == 1)
		normal += (texture2D(normal_map, v_vTexcoord).rgb * 2. - 1.) * normal_strength;
	
	gl_FragData[2] = vec4(normalize(normal), 1.);
}
