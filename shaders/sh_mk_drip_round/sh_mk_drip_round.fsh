varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float radius;

void main() {
	vec2 tx = 1. / dimension;
	
	vec4 res = texture2D(gm_BaseTexture, v_vTexcoord);
	
	float total = 0.;
	float fluid = 0.;
	
	for(float x = -radius; x <= radius; x++ )
	for(float y = -radius; y <= radius; y++ ) {
		vec2 sampPos = v_vTexcoord + vec2(y,x) * tx;
		vec4 sampCol = texture2D(gm_BaseTexture, sampPos);
		
		if(sampCol.a > 0.) fluid++;
		total++;
	}
	
	res.a = step(.1, fluid / total);
	
	gl_FragColor = res;
}