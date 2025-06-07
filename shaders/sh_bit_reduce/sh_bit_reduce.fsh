varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int  space;
uniform vec3 quantize;
uniform float alphaStep;

uniform int   dithering;
uniform float ditherContrast;
uniform float ditherSize;
uniform float dither[64];

#region =========================================== COLORS SPACES ===========================================
	
	const mat3 RGB2YIQ = mat3(0.30,   0.59,    0.11, 
	                          0.599, -0.2773, -0.3217, 
	                          0.213, -0.5251,  0.3121);
	             
	const mat3 YIQ2RGB = mat3(1.,  0.9496,  0.6236, 
	                          1., -0.2748, -0.6357, 
	                          1., -1.1000,  1.7000);
	

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
	
	vec3 rgb2oklab(vec3 c) {
		const mat3 kCONEtoLMS = mat3(                
	         0.4121656120,  0.2118591070,  0.0883097947,
	         0.5362752080,  0.6807189584,  0.2818474174,
	         0.0514575653,  0.1074065790,  0.6302613616);
	    
		c = pow(c, vec3(2.2));
		c = pow( kCONEtoLMS * c, vec3(1.0 / 3.0) );
		
		return c;
	}
	
	vec3 oklab2rgb(vec3 c) {
		const mat3 kLMStoCONE = mat3(
	         4.0767245293, -1.2681437731, -0.0041119885,
	        -3.3072168827,  2.6093323231, -0.7034763098,
	         0.2307590544, -0.3411344290,  1.7068625689);
        
		c = kLMStoCONE * (c * c * c);
		c = pow(c, vec3(1. / 2.2));
		
	    return c;
	}
	
#endregion =========================================== COLORS SPACES ===========================================

float ditherVal;

float min3(float a, float b, float c) { return min(min(a,b), min(a,c)); }
float max3(float a, float b, float c) { return max(max(a,b), max(a,c)); }

float quant(float n, float q) {
	if(q <= 1.) return floor(n + .5);
	
	float qz = floor(n * q) / (q - 1.);
	if(abs(n - qz) < 0.001 || dithering == 0) return qz;
	
	float iq  = 1. / (q - 1.);
	
	float bz  = floor(n * q + .5) / q;
	float dt  = n - bz;
	float dt0 = n - (bz - iq);
	float dt1 = n - (bz + iq);
	
	dt  *= q * 2.;
	dt0 *= q * 2.;
	dt1 *= q * 2.;
	
	float rat = min3(abs(dt), abs(dt0), abs(dt1));
	      rat = 1. - rat * ditherContrast;
	
	if(sign(dt) == 1.) return rat * .5 >= ditherVal? qz - iq : qz;
	else               return rat * .5 <= ditherVal? qz : qz + iq;
}

void main() {
	vec2 tx  = 1. / dimension;
	vec2 px  = floor(v_vTexcoord * dimension);
	vec4 cc  = texture2D(gm_BaseTexture, v_vTexcoord);
	vec3 cvt = cc.rgb;
	
	     if(space == 1) cvt = rgb2hsv(cc.rgb);
	else if(space == 2) cvt = rgb2oklab(cc.rgb);
	else if(space == 3) cvt = RGB2YIQ * cc.rgb;
	
	float col = px.x - floor(px.x / ditherSize) * ditherSize;
	float row = px.y - floor(px.y / ditherSize) * ditherSize;
	ditherVal = (dither[int(row * ditherSize + col)]) / (ditherSize * ditherSize - 1.);
	
	cvt.x = quant(cvt.x, quantize.x);
	cvt.y = quant(cvt.y, quantize.y);
	cvt.z = quant(cvt.z, quantize.z);
	
	vec3 fin = cvt;
	
	     if(space == 1) fin = hsv2rgb(cvt);
	else if(space == 2) fin = oklab2rgb(cvt);
	else if(space == 3) fin = YIQ2RGB * cvt;
	
	float _a = floor(cc.a * alphaStep) / (alphaStep - 1.);
	
	gl_FragColor = vec4(fin, _a);
}