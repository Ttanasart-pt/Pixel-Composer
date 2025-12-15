varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2      epsilon;
uniform int       epsilonUseSurf;
uniform sampler2D epsilonSurf;

uniform vec2      smoothness;
uniform int       smoothnessUseSurf;
uniform sampler2D smoothnessSurf;

float tanh(float x) { // tanh implementation by XOR
    float exp_neg_2x = exp(-2.0 * x);
    return -1.0 + 2.0 / (1.0 + exp_neg_2x);
}

void main() {
	float eps = epsilon.x;
	if(epsilonUseSurf == 1) {
		vec4 _vMap = texture2D( epsilonSurf, v_vTexcoord );
		eps = mix(epsilon.x, epsilon.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float smt = smoothness.x;
	if(smoothnessUseSurf == 1) {
		vec4 _vMap = texture2D( smoothnessSurf, v_vTexcoord );
		smt = mix(smoothness.x, smoothness.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec4  samp = texture2D(gm_BaseTexture, v_vTexcoord);
	float ss = (samp.r + samp.g + samp.b) / 3. * samp.a;
	
	float g = smoothstep(max(0., eps - smt), min(eps + smt, 1.), ss);
	
	gl_FragColor = vec4(g,g,g,1.);
}