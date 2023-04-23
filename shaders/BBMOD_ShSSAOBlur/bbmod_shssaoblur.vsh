attribute vec4 in_Position;     // (x,y,z,w)
attribute vec2 in_TextureCoord; // (u,v)

varying vec2 v_vTexCoord;

void main()
{
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * in_Position;
	v_vTexCoord = in_TextureCoord;
}
