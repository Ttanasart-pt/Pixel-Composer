//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int colors;
uniform int alpha;

uniform vec2      gamma;
uniform int       gammaUseSurf;
uniform sampler2D gammaSurf;

void main() {
	float gam = gamma.x;
	if(gammaUseSurf == 1) {
		vec4 _vMap = texture2D( gammaSurf, v_vTexcoord );
		gam = mix(gamma.x, gamma.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec4 _col = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 c = _col;
	c = floor(pow(c, vec4(gam)) * float(colors));
	c = pow(c / float(colors), vec4(1.0 / gam));
	
	if(alpha == 1)	gl_FragColor = c;
	else			gl_FragColor = vec4(c.rgb, _col.a);
}
