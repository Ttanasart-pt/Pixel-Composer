attribute vec4 in_Position;
attribute vec2 in_TextureCoord;

varying vec4 v_vColour;

uniform sampler2D u_texTest;

void main()
{
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * in_Position;
	v_vColour = texture2DLod(u_texTest, in_TextureCoord, 0.0);
}
