//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int  type;

vec4 sample( vec2 pos ) {
	if(pos.x < 0. || pos.y < 0.) return vec4(0.);
	if(pos.x > 1. || pos.y > 1.) return vec4(0.);
	
	return texture2D( gm_BaseTexture, pos );
}

void main() {
	vec2 tx = 1. / dimension;
	vec4 a  = sample( v_vTexcoord );
	gl_FragColor = a;
	
	if(type == 0) return;
	if(type == 2 && v_vTexcoord.x > 0.5) return;
	if(type == 3 && v_vTexcoord.y > 0.5) return;
	
	bool a0 = sample( v_vTexcoord + vec2(-tx.x, -tx.y) ).a == 1.;
	bool a1 = sample( v_vTexcoord + vec2(   .0, -tx.y) ).a == 1.;
	bool a2 = sample( v_vTexcoord + vec2( tx.x, -tx.y) ).a == 1.;
	
	bool a3 = sample( v_vTexcoord + vec2(-tx.x,    .0) ).a == 1.;
	bool a4 = a.a == 1.;
	bool a5 = sample( v_vTexcoord + vec2( tx.x,    .0) ).a == 1.;
	
	bool a6 = sample( v_vTexcoord + vec2(-tx.x,  tx.y) ).a == 1.;
	bool a7 = sample( v_vTexcoord + vec2(   .0,  tx.y) ).a == 1.;
	bool a8 = sample( v_vTexcoord + vec2( tx.x,  tx.y) ).a == 1.;
	
    // 0 1 2
	// 3 4 5
	// 6 7 8
	
	if(a.a == 0.) {
		/**/ if(a0 && a1 && a2 && a3 && !a5 && a6 && !a7 && !a8)
			gl_FragColor = vec4(1.);
		else if(a0 && a1 && a2 && !a3 && a5 && !a6 && !a7 && a8)
			gl_FragColor = vec4(1.);
		else if(a0 && !a1 && !a2 && a3 && !a5 && a6 && a7 && a8)
			gl_FragColor = vec4(1.);
		else if(!a0 && !a1 && a2 && !a3 && a5 && a6 && a7 && a8)
			gl_FragColor = vec4(1.);
		
		else if(a3 && a5)
			gl_FragColor = vec4(1.);
		else if(a1 && a7)
			gl_FragColor = vec4(1.);
	} else {
		/**/ if(a0 && a1 && !a2 && a3 && !a5 && !a6 && !a7 && !a8)
			gl_FragColor = vec4(0.);
		else if(!a0 && a1 && a2 && !a3 && a5 && !a6 && !a7 && !a8)
			gl_FragColor = vec4(0.);
		else if(!a0 && !a1 && !a2 && a3 && !a5 && a6 && a7 && !a8)
			gl_FragColor = vec4(0.);
		else if(!a0 && !a1 && !a2 && !a3 && a5 && !a6 && a7 && a8)
			gl_FragColor = vec4(0.);
			
		else if(!a3 && !a5)
			gl_FragColor = vec4(0.);
		else if(!a1 && !a7)
			gl_FragColor = vec4(0.);
	}
}
