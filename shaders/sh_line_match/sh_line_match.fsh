varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform int   iradius;
uniform int   fade;
uniform int   oneSide;

uniform float intensity;
uniform vec4  color;

#define TAU 6.28318530718

void main() {
	vec2 tx = 1. / dimension;
	
	float radius = float(iradius);
	float aCount = 64.;
	float aStep  = TAU / aCount;

	float maxAngle = 0.;
	float maxWeigh = 0.;
	
	for(float a = 0.; a < TAU; a += aStep) {
		vec2  offset = vec2(cos(a), sin(a)) * tx;
		vec2  posStr = v_vTexcoord;
		float weigh  = 0.;
		
		if(oneSide == 1) {
			posStr += offset * radius;
			offset /= 2.;
		}
		
		for(float r = -radius; r <= radius; r++) {
			vec4  sam = texture2D(gm_BaseTexture, posStr + offset * r);
			float wgh = sam.r * sam.a;
			weigh += wgh;
		}
		
		if(weigh > maxWeigh) {
			maxWeigh = weigh;
			maxAngle = a;
		}
	}
	
	float aa = maxAngle / TAU;
	aa *= intensity;
	
	vec3 clr = color.rgb * aa;
	if(fade == 1) clr *= maxWeigh / (radius * 2. + 1.);
	
	gl_FragColor = vec4(clr, 1.);
}