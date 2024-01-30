varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D colorMap;

void main() {
    vec4 c = texture2D( gm_BaseTexture, v_vTexcoord );
	gl_FragColor = c;
	
	if(c.rgb == vec3(0.)) return;
	
	gl_FragColor = texture2D( colorMap, c.xy );
}
