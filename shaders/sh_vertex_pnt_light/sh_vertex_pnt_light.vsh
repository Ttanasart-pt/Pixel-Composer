//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord;

varying vec2 v_vTexcoord;
varying float v_vNormalLight;

uniform vec3  u_LightForward;

void main() {
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
	vec3 world_space_norm = normalize(mat3(gm_Matrices[MATRIX_WORLD]) * in_Normal);
	vec3 world_space_ligh = u_LightForward;
	
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
	float illumination    = -dot(world_space_norm, world_space_ligh);
	
    v_vTexcoord = in_TextureCoord;
	v_vNormalLight = clamp(illumination, 0., 1.);
}