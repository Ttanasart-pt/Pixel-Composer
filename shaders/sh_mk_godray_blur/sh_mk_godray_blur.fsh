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
	float rad      = range  * tx.x;
	
	vec4  lightVal = vec4(0.);
	float mspread  = ceil(spread);
	float weightTo = 0.;
	
	if(type == 0) {
		vec2  toLight = v_vTexcoord - originTx;
		float dist = distance(originTx, v_vTexcoord);
		float dirr = degrees(atan(toLight.y, toLight.x));
		
		float radInt   = (rad - dist) / rad;
		
		for(float i = -mspread; i <= mspread; i += .25) {
			float samDir = radians(dirr + i * radInt);
			vec4  samPos = texture2D(gm_BaseTexture, originTx + vec2(cos(samDir), sin(samDir)) * dist);
			if(samPos.a < baseC.a) continue;
			
			float sampI =  1. - (abs(i) / mspread);
			lightVal += samPos * sampI;
			weightTo += sampI;
		}
		
	} else if(type == 1 || type == 2) {
		float dist = distance(originTx, v_vTexcoord);
		vec2  dirr = normalize(originTx - .5).yx * tx * vec2(1., -1);
		
		for(float i = -mspread; i <= mspread; i += .25) {
			vec4  samPos = texture2D(gm_BaseTexture, v_vTexcoord + dirr * i * dist);
			// if(samPos.a < baseC.a) continue;
			
			float sampI =  1. - (abs(i) / mspread);
			lightVal += samPos * sampI;
			weightTo += sampI;
		}
	}
	
	if(weightTo > .001)
		lightVal /= weightTo;
	lightVal.a = max(lightVal.a, 0.);
	
	gl_FragColor = lightVal;
}