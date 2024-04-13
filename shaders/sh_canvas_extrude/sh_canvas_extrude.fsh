varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec2  shift;
uniform float itr;
uniform vec4  color;

void main() {
	vec4 c = texture2D( gm_BaseTexture, v_vTexcoord );
	gl_FragColor = c;
	
	if(c.a > 0.) return;
	
    vec2 shiftNorm = normalize(shift) / dimension;
	
	for(float i = 0.; i < itr; i++) {
		vec2 sx = v_vTexcoord - shiftNorm * i;
		vec4 sc = texture2D( gm_BaseTexture, sx );
		
		if(sc.a > 0.) {
			gl_FragColor = color;
			return;
		}
	}
}
