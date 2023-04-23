varying vec2 v_vTexCoord;

uniform sampler2D bbmod_Splatmap;
uniform int bbmod_SplatmapIndex;

void main()
{
	vec4 splatmap = texture2D(bbmod_Splatmap, v_vTexCoord);
	// splatmap[bbmod_SplatmapIndex] does not work in HTML5
	gl_FragColor.rgb = vec3((bbmod_SplatmapIndex == 0) ? splatmap.r
		: ((bbmod_SplatmapIndex == 1) ? splatmap.g
		: ((bbmod_SplatmapIndex == 2) ? splatmap.b
		: splatmap.a)));
	gl_FragColor.a = 1.0;
}
