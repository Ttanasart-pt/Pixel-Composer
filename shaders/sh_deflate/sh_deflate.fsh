varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D original;
uniform sampler2D sdf;

uniform vec2  dimension;
uniform float radius;
uniform float amount;
uniform float offset;

#define PI 3.14159265358979323846

void main() {
	vec2 tx = 1. / dimension;
	
	vec4 orig   = v_vColour * texture2D(original, v_vTexcoord);
	vec4 height = v_vColour * texture2D(sdf, v_vTexcoord);
	vec4 base   = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
	float aa    = orig.a;
	
	if(height.r < .9)
		aa *= step(offset, base.r);
	
	gl_FragColor = vec4(orig.rgb, aa);
}

// void main() {
// 	vec2 tx = 1. / dimension;
	
// 	vec4 orig = v_vColour * texture2D(original, v_vTexcoord);
// 	vec4 base = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
// 	float aa  = orig.a;
	
// 	float nor = base.r + PI;
// 	float str = base.g;
	
// 	vec2  norm = vec2(cos(nor), sin(nor)) * tx * str * amount;
	
// 	for(float r = 0.; r < radius; r++) {
// 		vec2 px = v_vTexcoord + norm * r;
// 		vec4 sm = texture2D(original, px);
		
// 		if(sm.a == 0.) {
// 			aa = 0.;
// 			break;
// 		}
// 	}
	
// 	gl_FragColor = vec4(orig.rgb, aa);
// }