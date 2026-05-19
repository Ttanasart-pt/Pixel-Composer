varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

uniform sampler2D replace;
uniform vec2 replace_dim;
uniform sampler2D findRes;
uniform float index;

vec4 blendColor(vec4 base, vec4 colr) {
	vec4 bg = base;
	vec4 fg = colr;
	
	float ba = bg.a;
	float ca = fg.a;
	float al = ca + ba * (1. - ca);
	
	vec4 res = ((bg * ba * (1. - ca)) + (fg * ca)) / al;
	res.a = al;
	
	return res;
}

void main() {
	vec2 px     = v_vTexcoord * dimension - (replace_dim - 1.);
	vec4 basCol = vec4(0.);
	
	for( float i = 0.; i < replace_dim.x; i++ ) 
	for( float j = 0.; j < replace_dim.y; j++ ) {
		vec2 uv = px + vec2(i, j);
		if(uv.x < 0. || uv.y < 0.) continue;
		
		vec4 wg = texture2D( findRes, uv / dimension );
		
		if(wg.r == 1. && abs(wg.g - index) < 0.01) {
			vec4 repCol = texture2D( replace, (replace_dim - vec2(i, j) - 1. + .5) / replace_dim );
			if(repCol.a <= 0.) continue;
			
			basCol = blendColor(basCol, repCol);
			
			gl_FragData[0] = basCol;
			gl_FragData[1] = vec4(1., 1., 1., basCol.a);
		}
	}
}
