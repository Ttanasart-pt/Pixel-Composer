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
		
	float height = 0.;
	float hdiv   = 0.;
	
	if(sweepT == 1) { 
		vec2  pt  = v_vTexcoord + vec2( 0., tx.y) * stepSize;
		float nt  = texture2D(normal, pt).y - .5;
		float h0t = sample(pt).r - nt / intensity;
		
		height += h0t; 
		hdiv += 1.; 
	}
		
	if(sweepL == 1) { 
		vec2  pl  = v_vTexcoord - vec2( tx.x, 0.) * stepSize;
		float nl  = texture2D(normal, pl).x - .5;
		float h0l = sample(pl).r - nl / intensity;
		
		height += h0l; 
		hdiv += 1.; 
	}
		
	if(sweepB == 1) { 
		vec2  pb  = vec2(v_vTexcoord.x, v_vTexcoord.y - tx.y * stepSize);
		float nb  = texture2D(normal, pb).y - .5;
		float h0b = sample(pb).r + nb / intensity;
		
		height += h0b; 
		hdiv += 1.; 
	}
		
	if(sweepR == 1) { 
		vec2  pr  = v_vTexcoord + vec2( tx.x, 0.) * stepSize;
		float nr  = texture2D(normal, pr).x - .5;
		float h0r = sample(pr).r + nr / intensity;
		
		height += h0r; 
		hdiv += 1.; 
	}
	
	if(hdiv > 0.) height /= hdiv;
	
	gl_FragColor = vec4(height, height, height, 1.);
}