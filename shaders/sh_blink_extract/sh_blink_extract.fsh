//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int useMask;
uniform sampler2D mask;

uniform vec4 colorTarget[32];
uniform int colorTargetAmount;

void main() {
	vec4 c1 = texture2D( gm_BaseTexture, v_vTexcoord );
    gl_FragColor = vec4(0.);
	
	if(useMask == 1) {
		vec4 m = texture2D( mask, v_vTexcoord );
		if((m.r + m.g + m.b) * m.a < 0.5) 
			return;
	}
	
	float minDist = 10.;
	for(int i = 0; i < colorTargetAmount; i++) {
		float dist = distance(colorTarget[i].rgb, c1.rgb);
		minDist = min(minDist, dist);
	}
	
	if(minDist > 0.001) return;
	
	gl_FragColor = vec4(1.);
}
