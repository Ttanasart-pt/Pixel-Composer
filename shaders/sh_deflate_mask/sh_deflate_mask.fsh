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
	
	if(baseW < .5) {
		gl_FragColor = vec4(0.);
		return;
	}
	
	float radius1 = radius + 1.;
	float minDist = radius1;
	
	for(float x = -radius1; x <= ceil(radius1); x++) 
	for(float y = -radius1; y <= ceil(radius1); y++) {
		float _x = min(x, radius1);
		float _y = min(y, radius1);
		
		float len = length(vec2(_x, _y));
		if(len > minDist) continue;
		
		vec2 sx = v_vTexcoord + vec2(_x, _y) * tx;
		vec4 sm = texture2D(gm_BaseTexture, sx);
		float ww = (sm.x + sm.y + sm.z) / 3. * sm.a;
		
		if(ww < .5) minDist = min(minDist, len); 
	}
	
	float mask = minDist / radius1;
	gl_FragColor = v_vColour * vec4(mask, baseW, 0., 1.);
}