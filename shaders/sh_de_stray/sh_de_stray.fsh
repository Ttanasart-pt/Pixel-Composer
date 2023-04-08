//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform float tolerance;

bool sameColor(in vec4 c1, in vec4 c2) {
	return length(c1 - c2) <= tolerance;
}

void main() {
	vec4 curr_color = texture2D( gm_BaseTexture, v_vTexcoord );
	
	vec2 _dim = 1. / dimension;
    
	vec4 T = texture2D( gm_BaseTexture, v_vTexcoord + vec2(0.,  _dim.y));
	vec4 B = texture2D( gm_BaseTexture, v_vTexcoord + vec2(0., -_dim.y));
    
	vec4 L = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-_dim.x, 0.));
	vec4 R = texture2D( gm_BaseTexture, v_vTexcoord + vec2( _dim.x, 0.));
	
	if(!sameColor(curr_color, T)) {
		if(sameColor(T, B) && sameColor(B, L) && sameColor(L, R))
			curr_color = T;
		else if(sameColor(T, L) && sameColor(T, R))
			curr_color = T;
		else if(sameColor(T, B) && sameColor(T, R))
			curr_color = T;
		else if(sameColor(T, B) && sameColor(T, L))
			curr_color = T;
	} else if(!sameColor(curr_color, B) && sameColor(B, L) && sameColor(B, R))
		curr_color = B;
	
	gl_FragColor = curr_color;
}
