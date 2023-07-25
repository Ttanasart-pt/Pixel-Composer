//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform float tolerance;

bool sameColor(in vec4 c1, in vec4 c2) { return length(c1.rgb * c1.a - c2.rgb * c2.a) <= tolerance; }
int  sameColorInt(in vec4 c1, in vec4 c2) { return sameColor(c1, c2)? 1 : 0; }

void main() {
	vec2 tx = 1. / dimension;
    
	vec4 a0 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tx.x, -tx.y));
	vec4 a1 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(   0., -tx.y));
	vec4 a2 = texture2D( gm_BaseTexture, v_vTexcoord + vec2( tx.x, -tx.y));
    
	vec4 a3 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tx.x, 0.));
	vec4 a4 = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 a5 = texture2D( gm_BaseTexture, v_vTexcoord + vec2( tx.x, 0.));
	
	vec4 a6 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tx.x,  tx.y));
	vec4 a7 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(   0.,  tx.y));
	vec4 a8 = texture2D( gm_BaseTexture, v_vTexcoord + vec2( tx.x,  tx.y));
	
	gl_FragColor = a4;
	if(sameColor(a1, a4)) return;
	
	bool sideEqual = sameColor(a1, a3) && sameColor(a1, a5) && sameColor(a1, a7);
	if(!sideEqual) return;
	
	int cornerEqual =   sameColorInt(a1, a0) 
					  + sameColorInt(a1, a2) 
					  + sameColorInt(a1, a6) 
					  + sameColorInt(a1, a8);
	
	if(cornerEqual == 4)
		gl_FragColor = a0;
}
