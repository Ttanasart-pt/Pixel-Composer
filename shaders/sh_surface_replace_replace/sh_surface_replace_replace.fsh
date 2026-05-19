varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D replace;
uniform vec2 replace_dim;
uniform sampler2D findRes;
uniform float index;

void main() {
    vec4 basCol = texture2D(gm_BaseTexture, v_vTexcoord);
    vec4 res    = texture2D( findRes, v_vTexcoord );
    
	if(res.a == 1. && abs(res.b - index) < 0.01) {
		vec4 repCol = texture2D( replace, res.rg );
		if(repCol.a <= 0.) return;
		
		gl_FragData[0] = repCol;
		gl_FragData[1] = vec4(1.);
	}
}
