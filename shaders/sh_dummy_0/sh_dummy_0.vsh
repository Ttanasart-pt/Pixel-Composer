attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec2 v_vTexcoord;

uniform float u_float_0, u_float_1, u_float_2, u_float_3, u_float_4, u_float_5, u_float_6, u_float_7;
uniform float u_float_8, u_float_9, u_float_10, u_float_11, u_float_12, u_float_13, u_float_14, u_float_15;

uniform int u_int_0, u_int_1, u_int_2, u_int_3, u_int_4, u_int_5, u_int_6, u_int_7;
uniform int u_int_8, u_int_9, u_int_10, u_int_11, u_int_12, u_int_13, u_int_14, u_int_15;

uniform vec2 u_vec2_0, u_vec2_1, u_vec2_2, u_vec2_3, u_vec2_4, u_vec2_5, u_vec2_6, u_vec2_7;
uniform vec2 u_vec2_8, u_vec2_9, u_vec2_10, u_vec2_11, u_vec2_12, u_vec2_13, u_vec2_14, u_vec2_15;

uniform vec3 u_vec3_0, u_vec3_1, u_vec3_2, u_vec3_3, u_vec3_4, u_vec3_5, u_vec3_6, u_vec3_7;
uniform vec3 u_vec3_8, u_vec3_9, u_vec3_10, u_vec3_11, u_vec3_12, u_vec3_13, u_vec3_14, u_vec3_15;

uniform vec4 u_vec4_0, u_vec4_1, u_vec4_2, u_vec4_3, u_vec4_4, u_vec4_5, u_vec4_6, u_vec4_7;
uniform vec4 u_vec4_8, u_vec4_9, u_vec4_10, u_vec4_11, u_vec4_12, u_vec4_13, u_vec4_14, u_vec4_15;

uniform mat3 u_mat3_0, u_mat3_1, u_mat3_2, u_mat3_3, u_mat3_4, u_mat3_5, u_mat3_6, u_mat3_7;
uniform mat3 u_mat3_8, u_mat3_9, u_mat3_10, u_mat3_11, u_mat3_12, u_mat3_13, u_mat3_14, u_mat3_15;

uniform mat4 u_mat4_0, u_mat4_1, u_mat4_2, u_mat4_3, u_mat4_4, u_mat4_5, u_mat4_6, u_mat4_7;
uniform mat4 u_mat4_8, u_mat4_9, u_mat4_10, u_mat4_11, u_mat4_12, u_mat4_13, u_mat4_14, u_mat4_15;

uniform sampler2D  u_sampler2D_0,  u_sampler2D_1,  u_sampler2D_2,  u_sampler2D_3,  u_sampler2D_4,  u_sampler2D_5,  u_sampler2D_6; 

void main() {
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vTexcoord = in_TextureCoord;
}
