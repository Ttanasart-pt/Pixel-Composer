//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

void main() {
	gl_FragColor = vec4(0.);
	
	vec2 tx = 1. / dimension;
	
	float p  = texture2D( gm_BaseTexture, v_vTexcoord ).a > 0.? 1. : 0.;
	float p1 = texture2D( gm_BaseTexture, v_vTexcoord - vec2(0., tx.y) ).a > 0.? 1. : 0.;
	float p3 = texture2D( gm_BaseTexture, v_vTexcoord - vec2(tx.x, 0.) ).a > 0.? 1. : 0.;
	float p5 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(tx.x, 0.) ).a > 0.? 1. : 0.;
	float p7 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(0., tx.y) ).a > 0.? 1. : 0.;
	
	if(p1 != p7 || p3 != p5) {
		if(p == 0.) gl_FragColor = v_vColour;
		if(p == 1.) gl_FragColor = vec4(0., 0., 0., 1.);
	}
}
