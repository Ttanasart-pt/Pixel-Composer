varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float radius;

void main() {
	vec2 tx = 1. / dimension;
	float val = 0.;
	
	for(float i = -radius; i <= radius; i++)
	for(float j = -radius; j <= radius; j++) {
		vec4  sam = texture2D(gm_BaseTexture, clamp(v_vTexcoord + vec2(i,j) * tx, 0., 1.));
		float brg = (sam.r + sam.g + sam.b) / 3. * sam.a;
		
		float ind  = (i + radius) * radius * 2. + j + radius;
		float dist = 1. - length(vec2(i,j)) / radius;
		
		val += pow(2., ind) * brg;// * dist * dist;
	}
	
	gl_FragColor = vec4(val, 0., 0., 1.);
}