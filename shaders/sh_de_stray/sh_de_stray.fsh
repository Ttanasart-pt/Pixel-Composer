//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform float tolerance;

bool sameColor(in vec4 c1, in vec4 c2) {
	if(abs(c1.r - c2.r) > tolerance) return false;	
	if(abs(c1.g - c2.g) > tolerance) return false;	
	if(abs(c1.b - c2.b) > tolerance) return false;	
	if(abs(c1.a - c2.a) > tolerance) return false;	
	
	return true;
}

void main() {
	vec4 curr_color = texture2D( gm_BaseTexture, v_vTexcoord );
	
	vec2 _dim = 1. / dimension;
    
	vec4 col_t = texture2D( gm_BaseTexture, v_vTexcoord + vec2(0.,  _dim.y));
	vec4 col_b = texture2D( gm_BaseTexture, v_vTexcoord + vec2(0., -_dim.y));
    
	vec4 col_l = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-_dim.x, 0.));
	vec4 col_r = texture2D( gm_BaseTexture, v_vTexcoord + vec2( _dim.x, 0.));
	
	if(!sameColor(curr_color, col_t)) {
		if(sameColor(col_t, col_b) && sameColor(col_b, col_l) && sameColor(col_l, col_r))
			curr_color = col_t;
		else if(sameColor(col_t, col_l) && sameColor(col_t, col_r))
			curr_color = col_t;
		else if(sameColor(col_t, col_b) && sameColor(col_t, col_r))
			curr_color = col_t;
		else if(sameColor(col_t, col_b) && sameColor(col_t, col_l))
			curr_color = col_t;
	} else if(!sameColor(curr_color, col_b) && sameColor(col_b, col_l) && sameColor(col_b, col_r))
		curr_color = col_b;
	
	gl_FragColor = curr_color;
}
