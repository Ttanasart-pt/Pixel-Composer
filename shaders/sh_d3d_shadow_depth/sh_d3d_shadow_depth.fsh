varying float v_LightDepth;
uniform int   use_8bit;

vec3 floatToUnorm(float v) { 
	v *= 65536.;
	
	float r = floor(v / 65536.); v -= 65536. * r;
	float g = floor(v /   256.); v -=   256. * g;
	float b = floor(v);
	
	return vec3(r, g, b) / 256.; 
}
	
void main() {
	float d = v_LightDepth;
	
	if(use_8bit == 1) gl_FragColor = vec4(floatToUnorm(d), 1.);
	else              gl_FragColor = vec4(vec3(d), 1.);
}
