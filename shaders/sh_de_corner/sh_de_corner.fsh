//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform float tolerance;

bool sameColor(in vec4 c1, in vec4 c2) { return length(c1 - c2) <= tolerance; }
float bright(in vec4 c) { return dot(c.rgb, vec3(0.2126, 0.7152, 0.0722)) * c.a; }

vec4 sample(vec2 st) {
	if(st.x < 0. || st.y < 0.) return vec4(0.);
	if(st.x > 1. || st.y > 1.) return vec4(0.);
	return texture2D( gm_BaseTexture, st);
}

void main() {
	/*
		A B C
		D E F
		G H I
	*/
	vec4 E   = texture2D( gm_BaseTexture, v_vTexcoord );
	vec2 dim = 1. / dimension;
	gl_FragColor = E;
	
	if(E.a == 0.) return;
	
	vec4 e = E;
	
	vec4 A = sample( v_vTexcoord + vec2(-dim.x,  dim.y) );
	vec4 B = sample( v_vTexcoord + vec2(    0.,  dim.y) );
	vec4 C = sample( v_vTexcoord + vec2( dim.x,  dim.y) );
													    
	vec4 D = sample( v_vTexcoord + vec2(-dim.x,     .0) );
	vec4 F = sample( v_vTexcoord + vec2( dim.x,     .0) );
													    
	vec4 G = sample( v_vTexcoord + vec2(-dim.x, -dim.y) );
	vec4 H = sample( v_vTexcoord + vec2(    0., -dim.y) );
	vec4 I = sample( v_vTexcoord + vec2( dim.x, -dim.y) );
		
	if(sameColor(F, H) && sameColor(E, B) && sameColor(E, D) && sameColor(E, A) && !sameColor(E, C) && !sameColor(E, F) && !sameColor(E, G) && !sameColor(E, H)) {
		E = I.a == 0.? F : I;
		if(bright(E) < bright(e))
			gl_FragColor = E;
		return;
	}
	if(sameColor(D, H) && sameColor(E, B) && sameColor(E, C) && sameColor(E, F) && !sameColor(E, A) && !sameColor(E, D) && !sameColor(E, H) && !sameColor(E, I)) {
		E = G.a == 0.? D : G;
		if(bright(E) < bright(e))
			gl_FragColor = E;
		return;
	}
	if(sameColor(F, B) && sameColor(E, D) && sameColor(E, G) && sameColor(E, H) && !sameColor(E, A) && !sameColor(E, B) && !sameColor(E, F) && !sameColor(E, I)) {
		E = C.a == 0.? F : C;
		if(bright(E) < bright(e))
			gl_FragColor = E;
		return;
	}
	if(sameColor(D, B) && sameColor(E, F) && sameColor(E, I) && sameColor(E, H) && !sameColor(E, C) && !sameColor(E, B) && !sameColor(E, D) && !sameColor(E, G)) {
		E = A.a == 0.? D : A;
		if(bright(E) < bright(e))
			gl_FragColor = E;
		return;
	}
}
