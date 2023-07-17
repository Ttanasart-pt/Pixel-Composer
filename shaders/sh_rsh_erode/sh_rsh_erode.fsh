//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

vec4 sample( vec2 pos ) {
	if(pos.x < 0. || pos.y < 0.) return vec4(0.);
	if(pos.x > 1. || pos.y > 1.) return vec4(0.);
	
	return texture2D( gm_BaseTexture, pos );
}

void main() {
	vec2 tx = 1. / dimension;
	vec4 a = sample( v_vTexcoord );
	gl_FragColor = a;
	if(a.a == 0.) return;
	
	bool a1 = sample( v_vTexcoord + vec2(   .0, -tx.y) ).a == 1.;
	bool a3 = sample( v_vTexcoord + vec2(-tx.x,    .0) ).a == 1.;
	bool a4 = a.a == 1.;
	bool a5 = sample( v_vTexcoord + vec2( tx.x,    .0) ).a == 1.;
	bool a7 = sample( v_vTexcoord + vec2(   .0,  tx.y) ).a == 1.;
	
    // 0 1 2
	// 3 4 5
	// 6 7 8
	
	if(!a1 || !a3 || !a5 || !a7)
		gl_FragColor = vec4(0.);
}
