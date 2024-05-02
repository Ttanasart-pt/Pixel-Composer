varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int  blend;
uniform vec4 color;
uniform sampler2D mask;

void main() {
	vec4 red = vec4(1., 0., 0., 1.);
    vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
    vec4 msk = texture2D( mask, v_vTexcoord );
	
	gl_FragColor = col;
	if(msk != red) return;
	
		 if(blend == 0) gl_FragColor = color;
	else if(blend == 1) gl_FragColor = color * col;
}
