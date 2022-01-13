//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

void main() {
	/*
		A B C
		D E F
		G H I
	*/
	vec4 E = texture2D( gm_BaseTexture, v_vTexcoord );
	vec2 dim = 1. / dimension;
	
	if(E.a > 0.) {
		vec4 A = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-dim.x,  dim.y));
		vec4 B = texture2D( gm_BaseTexture, v_vTexcoord + vec2(    0.,  dim.y));
		vec4 C = texture2D( gm_BaseTexture, v_vTexcoord + vec2( dim.x,  dim.y));
		
		vec4 D = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-dim.x,     .0));
		vec4 F = texture2D( gm_BaseTexture, v_vTexcoord + vec2( dim.x,     .0));
		
		vec4 G = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-dim.x, -dim.y));
		vec4 H = texture2D( gm_BaseTexture, v_vTexcoord + vec2(    0., -dim.y));
		vec4 I = texture2D( gm_BaseTexture, v_vTexcoord + vec2( dim.x, -dim.y));
		
		if(B.a > 0. && D.a > 0. && C.a + F.a + H.a + G.a == 0.)
			E.a = 0.;
		else if(B.a > 0. && F.a > 0. && A.a + D.a + H.a + I.a == 0.)
			E.a = 0.;
		else if(H.a > 0. && D.a > 0. && A.a + B.a + F.a + I.a == 0.)
			E.a = 0.;
		else if(H.a > 0. && F.a > 0. && B.a + C.a + D.a + G.a == 0.)
			E.a = 0.;
	}
	
	gl_FragColor = E;
}
