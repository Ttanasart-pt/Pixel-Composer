varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D textureMap;

void main() {
    vec4 c = texture2D( gm_BaseTexture, v_vTexcoord );
    
	if(c.rgb == vec3(0.)) {
		gl_FragColor = vec4(0.);
		return;
	}
	
	vec2 t = (v_vTexcoord - c.xy) / (c.zw - c.xy);
	gl_FragColor = texture2D( textureMap, t );
}
