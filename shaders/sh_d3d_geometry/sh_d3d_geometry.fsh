varying vec2 v_vTexcoord;
varying vec4 v_worldPosition;
varying vec3 v_viewPosition;
varying vec3 v_vNormal;
varying vec3 v_viewNormal;

uniform int       use_normal;
uniform int       use_8bit;
uniform float     normal_strength;
uniform sampler2D normal_map;

uniform int       mat_flip;
uniform vec2      mat_texScale;
uniform vec2      mat_texShift;

void main() {
	vec2 uv_coord = v_vTexcoord;
	if(mat_flip == 1) uv_coord.y = -uv_coord.y;
	uv_coord = fract(uv_coord * mat_texScale + mat_texShift);
	
	vec4 mat_baseColor = texture2D( gm_BaseTexture, uv_coord );
	if(mat_baseColor.a < 0.1) discard;
	
	vec3 normal = v_vNormal;
	if(use_normal == 1) normal += (texture2D(normal_map, uv_coord).rgb * 2. - 1.) * normal_strength;
	
	gl_FragData[0] = vec4( v_worldPosition.xyz, mat_baseColor.a);
	gl_FragData[1] = vec4( v_viewPosition,      mat_baseColor.a);
	gl_FragData[2] = vec4( normalize(normal),   mat_baseColor.a);
	gl_FragData[3] = vec4( v_viewNormal,        mat_baseColor.a);
}
