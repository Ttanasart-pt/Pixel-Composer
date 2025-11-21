varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float hueShift, hueMinS, hueMinE, hueMaxS, hueMaxE;
uniform float satShift, satMinS, satMinE, satMaxS, satMaxE;
uniform float valShift, valMinS, valMinE, valMaxS, valMaxE;

uniform int alpha;

#region =========================================== COLORS SPACES ===========================================
	vec3 rgb2hsv(vec3 c) {
		vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	
	    float d = q.x - min(q.w, q.y);
	    float e = 0.0000000001;
	    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
	 }
	
	vec3 hsv2rgb(vec3 c) {
	    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
	}
	
#endregion =========================================== COLORS SPACES ===========================================

float rangeVal(float val, float minS, float minE, float maxS, float maxE) {
	
	if(val <= minS || val >= maxE) return 0.;
	if(val >= minE && val <= maxS) return 1.;
	
	if(val < minE) return      (val - minS) / (minE - minS);
	if(val > maxS) return 1. - (val - maxS) / (maxE - maxS);
	
	return 0.;
}

void main() {
	vec4  baseCol = texture2D(gm_BaseTexture, v_vTexcoord);
	vec3  baseHSV = rgb2hsv(baseCol.rgb);
	float hue     = fract(baseHSV.x - hueShift);
	
	float s  = 1.;
	      s *= rangeVal(hue,       hueMinS, hueMinE, hueMaxS, hueMaxE);
	      s *= rangeVal(baseHSV.y, satMinS, satMinE, satMaxS, satMaxE);
	      s *= rangeVal(baseHSV.z, valMinS, valMinE, valMaxS, valMaxE);
	
	vec4 res = vec4(s,s,s, alpha == 1? baseCol.a : 1.);
	gl_FragColor = res;
}