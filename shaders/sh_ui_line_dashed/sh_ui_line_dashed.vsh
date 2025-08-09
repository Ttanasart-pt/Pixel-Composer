attribute vec3 in_Position;
attribute vec4 in_Colour;

varying vec4 v_vColour;
varying vec4 v_vPos;

void main() {
	vec4 object_space_pos = vec4(in_Position.x, in_Position.y, in_Position.z, 1.0);
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;

	v_vColour = in_Colour;
	v_vPos = object_space_pos;
}