varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float hueShift, hueMinS, hueMinE, hueMaxS, hueMaxE;

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float rangeVal(float val, float minS, float minE, float maxS, float maxE) {
	
	if(val <= minS || val >= maxE) return 0.;
	if(val >= minE && val <= maxS) return 1.;
	
	if(val < minE) return      (val - minS) / (minE - minS);
	if(val > maxS) return 1. - (val - maxS) / (maxE - maxS);
	
	return 0.;
}

void main() {
	vec4 cc  = texture2D(gm_BaseTexture, v_vTexcoord);
	vec3 hsv = vec3(fract(v_vTexcoord.x + hueShift), 1., 1.);
	
	float s = rangeVal(v_vTexcoord.x, hueMinS, hueMinE, hueMaxS, hueMaxE);
	if(1. - v_vTexcoord.y > s) cc.a *= .75;
	
	gl_FragColor = vec4(hsv2rgb(hsv), cc.a);
}