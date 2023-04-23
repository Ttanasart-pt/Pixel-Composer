varying vec2 v_vTexCoord;

void main()
{
	gl_FragColor = texture2D(gm_BaseTexture, v_vTexCoord);
}
