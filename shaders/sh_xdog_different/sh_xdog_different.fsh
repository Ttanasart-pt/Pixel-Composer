varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D g1;
uniform sampler2D g2;
uniform int edge;

uniform vec2      gamma;
uniform int       gammaUseSurf;
uniform sampler2D gammaSurf;

void main() {
	float gam = gamma.x;
	if(gammaUseSurf == 1) {
		vec4 _vMap = texture2D( gammaSurf, v_vTexcoord );
		gam = mix(gamma.x, gamma.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec4 s1 = texture2D(g1, v_vTexcoord);
	vec4 s2 = texture2D(g2, v_vTexcoord);
	
	gl_FragColor   = s1 - s2 * gam;
	if(edge == 1) gl_FragColor = abs(gl_FragColor);
	
	gl_FragColor.a = 1.;
}

