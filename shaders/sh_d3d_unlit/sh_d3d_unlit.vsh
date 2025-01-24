attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord;
attribute vec4 in_Colour;
attribute vec3 in_Barycentric;

varying vec2  v_vTexcoord;
varying vec4  v_vColour;
varying vec3  v_vNormal;
varying vec3  v_barycentric;

varying vec4  v_worldPosition;
varying vec3  v_viewPosition;
varying float v_cameraDistance;

uniform float planeNear;
uniform float planeFar;

void main() {
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
	
    v_worldPosition = gm_Matrices[MATRIX_WORLD] * object_space_pos;
	v_viewPosition  = gl_Position.xyz;
	
    v_vColour       = in_Colour;
    v_vTexcoord     = in_TextureCoord;
	
	vec3 worldNormal = normalize(gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.)).xyz;
	v_vNormal = worldNormal;
	
	float depthRange = abs(planeFar - planeNear);
	float ndcDepth   = (gl_Position.z - planeNear) / depthRange;
	v_cameraDistance = ndcDepth * 0.5 + 0.5;
	
	v_barycentric = in_Barycentric;
}
