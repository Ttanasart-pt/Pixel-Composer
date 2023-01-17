//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord;

varying vec3 v_vNormal;

void main() {
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
	vec3 world_space_norm = normalize(mat3(gm_Matrices[MATRIX_WORLD]) * in_Normal);
	
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vNormal = in_Normal;
}