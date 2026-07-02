varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float radius;
uniform float threshold;

#define TAU 6.28318530718

void main() {
	vec2  tx = 1. / dimension;
	vec4  cc = vec4(0.);
	float dv = 0.;
	
	int invert = 1;
	
	vec4 base = texture2D( gm_BaseTexture, v_vTexcoord );
	if(invert == 1) base = 1. - base;
	
	float aStep = TAU / 64.;
	for(float i = 0.; i < radius; i++)
	for(float j = 0.; j < TAU; j += aStep) {
		vec2  sx = v_vTexcoord + vec2(cos(j), sin(j)) * tx * i;
		vec4  c  = texture2D( gm_BaseTexture, sx );
		c.rgb *= c.a;
		
		if(invert == 1) c = 1. - c;
		
		cc += c;
		dv += 1.;
	}
	
	cc /= dv;
	
	vec4  res    = cc;
	float bright = (cc.r + cc.g + cc.b) / 3. * cc.a; 
	
	res = base * step(threshold, bright);
    
	if(invert == 1) res = 1. - res;
	gl_FragColor = res;
}