varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float expands;

void main() {
	vec2 tx = 1. / dimension;
	float w = texture2D(gm_BaseTexture, v_vTexcoord).r;
	gl_FragColor = vec4(w, 0., 0., 1.);
	
	if(w == 1.) return;
	
	for(float i = 1.; i <= expands; i++)
	for(float j = 0.; j < 64.; j++) {
		float a = radians(j / 64. * 360.);
		vec2 sx = v_vTexcoord + vec2(cos(a), sin(a)) * i * tx;
		
		w = texture2D(gm_BaseTexture, sx).r;
		if(w > 0.) {
			gl_FragColor = vec4(w, 0., 0., 1.);
			return;
		}
	}
	
}