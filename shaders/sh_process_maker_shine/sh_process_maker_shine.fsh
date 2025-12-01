varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float frame;
uniform float progress;

void main() {
	float shineLine = (v_vTexcoord.x + v_vTexcoord.y) / 2.;
	
	float span   = .5 * (1. - progress);
	float shine  =      step(progress * (1. - span), shineLine);
	      shine *= 1. - step(progress * (1. + span), shineLine);
	
	vec2 tx = .5 + (v_vTexcoord - .5) / (1. + shine * .1);
	vec4 cc = v_vColour * texture2D(gm_BaseTexture, tx);
	cc.rgb *= vec3(1. + shine * 1.);
	
	gl_FragColor = cc;
}