// FIXME: Temporary fix!
precision highp float;

attribute vec4 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord0;
attribute vec4 in_TangentW;

varying vec3 v_vNormal;
varying vec2 v_vTexCoord;

void main()
{
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * in_Position;
	v_vNormal = mat3(gm_Matrices[MATRIX_WORLD_VIEW]) * in_Normal;
	v_vTexCoord = in_TextureCoord0;
}
