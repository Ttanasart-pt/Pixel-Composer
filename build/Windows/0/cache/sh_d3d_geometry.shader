attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec2 v_vTexcoord;
varying vec4 v_worldPosition;
varying vec3 v_viewPosition;
varying vec3 v_vNormal;

uniform float planeNear;
uniform float planeFar;

void main() {
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
	
    v_worldPosition = gm_Matrices[MATRIX_WORLD] * object_space_pos;
    vec4 viewPos    = gm_Matrices[MATRIX_WORLD_VIEW] * object_space_pos;
	//viewPos.xy     /= viewPos.w;
	//viewPos.z       = (viewPos.z - planeNear - planeFar) / (planeFar - planeNear);
	v_viewPosition  = viewPos.xyz;
	
	 v_vTexcoord     = in_TextureCoord;
	 
	vec3 worldNormal = normalize(gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.)).xyz;
	v_vNormal = worldNormal;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
varying vec2 v_vTexcoord;
varying vec4 v_worldPosition;
varying vec3 v_viewPosition;
varying vec3 v_vNormal;

uniform int			mat_flip;
uniform int			use_normal;
uniform int         use_8bit;
uniform float		normal_strength;
uniform sampler2D	normal_map;

void main() {
	vec2 uv_coord = v_vTexcoord;
	if(mat_flip == 1) uv_coord.y = -uv_coord.y;
	vec4 mat_baseColor = texture2D( gm_BaseTexture, uv_coord );
	if(mat_baseColor.a < 0.1) discard;
	
	vec3 normal = v_vNormal;
	if(use_normal == 1) normal += (texture2D(normal_map, uv_coord).rgb * 2. - 1.) * normal_strength;
	
	gl_FragData[0] = vec4(v_worldPosition.xyz, mat_baseColor.a);
	gl_FragData[1] = vec4(v_viewPosition, mat_baseColor.a);
	gl_FragData[2] = vec4(normalize(normal), mat_baseColor.a);
}

