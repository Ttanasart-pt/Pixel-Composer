varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform sampler2D normal;

uniform float stepSize;
uniform float intensity;
uniform float totalStep;
uniform float currLoop;

uniform int sweepT;
uniform int sweepL;
uniform int sweepB;
uniform int sweepR;

vec4 sample(vec2 pos) { return texture2D(gm_BaseTexture, clamp(pos, 0., 1.)); }

void main() {
	vec2 tx = 1. / dimension;
	vec2 px = floor(v_vTexcoord * dimension);
	float h0 = sample(v_vTexcoord).r;
	
	float nl = texture2D(normal, v_vTexcoord - vec2( tx.x, 0.) * stepSize).x - .5;
	float hl = sample(v_vTexcoord - vec2( tx.x, 0.) * stepSize).r;
	float h0l = hl - nl / intensity;
	
	float nr = texture2D(normal, v_vTexcoord + vec2( tx.x, 0.) * stepSize).x - .5;
	float hr = sample(v_vTexcoord + vec2( tx.x, 0.) * stepSize).r;
	float h0r = hr + nr / intensity;
	
	float nt = texture2D(normal, v_vTexcoord + vec2( 0., tx.y) * stepSize).y - .5;
	float ht = sample(v_vTexcoord + vec2( 0., tx.y) * stepSize).r;
	float h0t = ht - nt / intensity;
	
	vec2  pb = vec2(v_vTexcoord.x, v_vTexcoord.y - tx.y * stepSize);
	float nb = texture2D(normal, pb).y - .5;
	float hb = sample(pb).r;
	float h0b = hb + nb / intensity;
	
	float height = 0.;
	float hdiv   = 0.;
	
	if(sweepT == 1) { height += h0t; hdiv += 1.; }
	if(sweepL == 1) { height += h0l; hdiv += 1.; }
	if(sweepB == 1) { height += h0b; hdiv += 1.; }
	if(sweepR == 1) { height += h0r; hdiv += 1.; }
	
	if(hdiv > 0.) height /= hdiv;
	
	gl_FragColor = vec4(height, height, height, 1.);
}