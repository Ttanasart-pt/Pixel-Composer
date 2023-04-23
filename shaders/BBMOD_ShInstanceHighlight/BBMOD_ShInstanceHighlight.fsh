varying vec2 v_vTexCoord;

uniform vec2 u_vTexel;
uniform vec4 u_vColor;

float IsInstance(vec2 uv)
{
	return (dot(texture2D(gm_BaseTexture, uv), vec4(1.0)) > 0.0) ? 1.0 : 0.0;
}

void main()
{
	float x = IsInstance(v_vTexCoord + vec2(-1.0, 0.0) * u_vTexel)
		- IsInstance(v_vTexCoord + vec2(+1.0, 0.0) * u_vTexel);
	float y = IsInstance(v_vTexCoord + vec2(0.0, -1.0) * u_vTexel)
		- IsInstance(v_vTexCoord + vec2(0.0, +1.0) * u_vTexel);
	gl_FragColor = u_vColor;
	gl_FragColor.a *= sqrt((x * x) + (y * y));
}
