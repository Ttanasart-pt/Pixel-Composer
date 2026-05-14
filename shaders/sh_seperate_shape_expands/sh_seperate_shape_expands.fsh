varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;

void main() {
	gl_FragColor = texture2D(gm_BaseTexture, v_vTexcoord);
	if(gl_FragColor != vec4(0.)) return;
	
	vec2 tx = 1. / dimension;
	
	for(float i = -1.; i <= 1.; i++)
	for(float j = -1.; j <= 1.; j++) {
		if(i == 0. && j == 0.) continue;
		
		vec2 pos   = clamp(v_vTexcoord + vec2(i, j) * tx, 0., 1.);
		vec4 samCl = texture2D(gm_BaseTexture, pos);
		if(samCl != vec4(0.)) {
			gl_FragColor = samCl;
			return;
		}
	}
}