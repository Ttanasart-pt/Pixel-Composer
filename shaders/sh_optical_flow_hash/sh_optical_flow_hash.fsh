varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float radius;

void main() {
	vec2 tx = 1. / dimension;
	vec4 val = vec4(0.);
	
	for(float i = -radius; i <= radius; i++)
	for(float j = -radius; j <= radius; j++) {
		vec4  sam = texture2D(gm_BaseTexture, clamp(v_vTexcoord + vec2(i,j) * tx, 0., 1.));
		float ind = (i + radius) * radius * 2. + j + radius;
		
		val += ind + sam * sam.a;
	}
	
	gl_FragColor = val;
}