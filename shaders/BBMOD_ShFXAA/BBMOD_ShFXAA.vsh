// Source: https://www.geeks3d.com/20110405/fxaa-fast-approximate-anti-aliasing-demo-glsl-opengl-test-radeon-geforce/3/
attribute vec4 in_Position;
attribute vec2 in_TextureCoord;

varying vec4 v_vFragPos;

uniform vec2 u_vTexelVS;

/// @param texCoord Texture coordinates.
/// @param texel    vec2(1.0 / textureWidth, 1.0 / textureHeight)
vec4 FXAAFragPos(vec2 texCoord, vec2 texel)
{
	vec4 pos;
	pos.xy = texCoord;
	pos.zw = texCoord - (texel * 0.75);
	return pos;
}

void main()
{
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * in_Position;
	v_vFragPos = FXAAFragPos(in_TextureCoord, u_vTexelVS);
}