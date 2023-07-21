//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int corner;
uniform int side;

vec4 sample ( vec2 position ) {
	if(position.x < 0.) return vec4(0.);
	if(position.y < 0.) return vec4(0.);
	if(position.x > 1.) return vec4(0.);
	if(position.y > 1.) return vec4(0.);
	
	return texture2D( gm_BaseTexture, position );
}

void main() {
	vec2 tx = 1. / dimension;
	
    gl_FragColor = sample( v_vTexcoord );
	float _s = float(side);
	
	if(gl_FragColor.a == _s) return;
	
	bool a0 = sample( v_vTexcoord + vec2( -tx.x, -tx.y) ).a == _s;
	bool a1 = sample( v_vTexcoord + vec2(    0., -tx.y) ).a == _s;
	bool a2 = sample( v_vTexcoord + vec2(  tx.x, -tx.y) ).a == _s;
				   
	bool a3 = sample( v_vTexcoord + vec2( -tx.x,    0.) ).a == _s;
	bool a5 = sample( v_vTexcoord + vec2(  tx.x,    0.) ).a == _s;
				   
	bool a6 = sample( v_vTexcoord + vec2( -tx.x,  tx.y) ).a == _s;
	bool a7 = sample( v_vTexcoord + vec2(    0.,  tx.y) ).a == _s;
	bool a8 = sample( v_vTexcoord + vec2(  tx.x,  tx.y) ).a == _s;
	
	if( a1 || a3 || a5 || a7 ) 
		gl_FragColor = v_vColour;
	if( corner == 1 && ( a0 || a2 || a6 || a8 ) ) 
		gl_FragColor = v_vColour;
}
