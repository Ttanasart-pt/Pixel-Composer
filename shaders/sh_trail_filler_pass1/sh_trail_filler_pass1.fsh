varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define TAU 6.283185307179586

uniform sampler2D prevFrame;
uniform sampler2D currFrame;

uniform vec2  dimension;
uniform float range;
uniform float alpha;

uniform int matchColor;
uniform int blendColor;

vec4 sampP( vec2 p ) { return texture2D( prevFrame, p ); }
vec4 sampC( vec2 p ) { return texture2D( currFrame, p ); }

void main() {
	gl_FragData[0] = vec4(0.);
	
	float cThr = 0.02;
	vec2  tx   = 1. / dimension;
	
	float base = 1.;
	float top  = 0.;
	float r2   = range * 2.;
	float ang;
	
	vec4 cc = sampC(v_vTexcoord);
	
	for(float a = 0.; a <= 64.; a++) {
		ang  = top / base * TAU;
		top += 2.;
		
		if(top >= base) {
			top   = 1.;
			base *= 2.;
		}
		
		vec2 sh = vec2(cos(ang), sin(ang)) * tx;
		
		vec2 p0 = v_vTexcoord;
		vec2 p1 = v_vTexcoord; 
		
		vec4 c0 = cc;
		vec4 c1 = cc;
		
		for(float i = 0.; i <= r2; i++) {
			if(c0.a > 0. && c1.a > 0.) {
				c0.a = alpha;
				gl_FragData[0] = c0;
				return;
			}
			
			if(c0.a == 0.) {
				p0 += sh;
				c0  = sampC(p0);
				
			} else {
				p1 -= sh;
				c1  = sampP(p1);
				
			}
		}
	}
	
}
