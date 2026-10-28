varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float radius;

void main() {
	vec2 tx = 1. / dimension;
	
	float weight      = 0.;
	float weightTotal = 0.;
	
	vec4  baseS = texture2D(gm_BaseTexture, v_vTexcoord);
	float baseW = (baseS.x + baseS.y + baseS.z) / 3. * baseS.a;
	
	for(float x = -radius; x <= radius; x++) 
	for(float y = -radius; y <= radius; y++) {
		vec2 sx = v_vTexcoord + vec2(x, y) * tx;
		vec4 sm = texture2D(gm_BaseTexture, sx);
		
		float ww = (sm.x + sm.y + sm.z) / 3. * sm.a;
		
		weight += ww;
		weightTotal++;
	}
	
	float mask = 1. - abs(weight / weightTotal - .5) * 2.;
	gl_FragColor = v_vColour * vec4(mask, baseW, 0., 1.);
}