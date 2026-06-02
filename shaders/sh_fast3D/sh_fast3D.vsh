attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord;
attribute vec4 in_Colour;

varying vec4 v_worldPosition;
varying vec3 v_viewPosition;

varying vec3 v_worldNormal;
varying vec3 v_viewNormal;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec3 cameraPosition;
uniform vec3 cameraDirection;

void main() {
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
	
    v_worldPosition = gm_Matrices[MATRIX_WORLD] * object_space_pos;
	v_viewPosition  = gl_Position.xyz;

	v_worldNormal   = normalize(gm_Matrices[MATRIX_WORLD]      * vec4(in_Normal, 0.)).xyz;
	v_viewNormal    = normalize(gm_Matrices[MATRIX_WORLD_VIEW] * vec4(in_Normal, 0.)).xyz;

    v_vTexcoord     = in_TextureCoord;
    v_vColour       = in_Colour;
}
