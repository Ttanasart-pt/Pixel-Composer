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
