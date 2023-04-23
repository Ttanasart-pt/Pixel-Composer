attribute vec4 in_Position;
attribute vec2 in_TextureCoord;

varying vec2 v_vTexCoord;

void main()
{
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * in_Position;
	v_vTexCoord = in_TextureCoord;
}
