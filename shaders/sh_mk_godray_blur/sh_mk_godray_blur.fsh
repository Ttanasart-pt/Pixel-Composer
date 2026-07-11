varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

uniform int   type;
uniform vec2  origin;
uniform float range;

uniform float spread;

void main() {
	vec4 baseC = texture2D(gm_BaseTexture, v_vTexcoord);
	
	if(spread <= 0.) {
		baseC.a = max(baseC.a, 0.);
		gl_FragColor = baseC;
		return;
	}
	
	vec2  tx       = 1. / dimension;
	vec2  originTx = origin * tx;
	vec2  toLight  = v_vTexcoord - originTx;
	float rad      = range  * tx.x;
	
	float dist     = distance(originTx, v_vTexcoord);
	float dirr     = degrees(atan(toLight.y, toLight.x));
	float radInt   = (rad - dist) / rad;
	
	float mspread  = ceil(spread);
	vec4  lightVal = vec4(0.);
	float weightTo = 0.;
	
	for(float i = -mspread; i <= mspread; i += .25) {
		float samDir = radians(dirr + i * radInt);
		vec4  samPos = texture2D(gm_BaseTexture, originTx + vec2(cos(samDir), sin(samDir)) * dist);
		if(samPos.a < baseC.a) continue;
		
		float ints   =  1. - (abs(i) / mspread);
		
		lightVal += samPos * ints;
		weightTo += ints;
	}
	
	if(weightTo > .001)
		lightVal /= weightTo;
	lightVal.a = max(lightVal.a, 0.);
	gl_FragColor = lightVal;
}