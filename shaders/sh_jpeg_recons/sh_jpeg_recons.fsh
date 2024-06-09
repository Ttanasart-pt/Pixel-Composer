#define PI    3.1415972
#define SQRT2 0.70710678118

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform int   patch;
uniform int   transform;
uniform int   reconstruct;
uniform float phase;

float DCTcoeff(vec2 k, vec2 x) { return cos(PI * k.x * x.x + phase) * cos(PI * k.y * x.y + phase); }
float ZIGcoeff(vec2 k, vec2 x) { 
	float a, b;
	
	float fx = fract(k.x * x.x + phase / PI / 2. + .5);
	a = fx < 0.5? fx * 2. : (1. - fx) * 2.;
	a = a * 2. - 1.;
	
	float fy = fract(k.y * x.y + phase / PI / 2. + .5);
	b = fy < 0.5? fy * 2. : (1. - fy) * 2.;
	b = b * 2. - 1.;
	
	return a * b;
}

float SMTcoeff(vec2 k, vec2 x) { 
	float a, b;
	
	float fx = fract(k.x * x.x + phase / PI / 2. + .5);
	a = fx < 0.5? fx * 2. : (1. - fx) * 2.;
	a = smoothstep(0., 1., a);
	a = a * 2. - 1.;
	
	float fy = fract(k.y * x.y + phase / PI / 2. + .5);
	b = fy < 0.5? fy * 2. : (1. - fy) * 2.;
	b = smoothstep(0., 1., b);
	b = b * 2. - 1.;
	
	return a * b;
}

float STPcoeff(vec2 k, vec2 x) { 
	float a, b;
	float sp = 1. / 2.;
	
	float _fx = fract(k.x * x.x + phase / PI / 2.);
	float fx  = _fx >= 0.5 - sp && _fx <= 0.5 + sp? 0. : step(0.5, _fx);
	a = a * 2. - 1.;
	
	float _fy = fract(k.y * x.y + phase / PI / 2.);
	float fy  = _fy >= 0.5 - sp && _fy <= 0.5 + sp? 0. : step(0.5, _fy);
	b = b * 2. - 1.;
	
	return a * b;
}

void main() {
    vec2 tx = dimension * v_vTexcoord;
    
    vec2 k = mod(tx, float(patch)) - .5;
    vec2 K = floor(tx - k);
    
    vec4 val = vec4(0.);
    for(int u = 0; u < reconstruct; ++u)
	for(int v = 0; v < reconstruct; ++v) {
	    
	    vec4  s = texture2D( gm_BaseTexture, (K + vec2(u, v) + .5) / dimension);
	    float c = 0.;
	    
	    	 if(transform == 0) c = DCTcoeff(vec2(u, v), (k + .5) / float(patch));
	    else if(transform == 1) c = ZIGcoeff(vec2(u, v), (k + .5) / float(patch));
	    else if(transform == 2) c = SMTcoeff(vec2(u, v), (k + .5) / float(patch));
	    else if(transform == 3) c = STPcoeff(vec2(u, v), (k + .5) / float(patch));
	    
	    c *= u == 0? SQRT2 : 1.;
	    c *= v == 0? SQRT2 : 1.;
	    
        val += s * c;
    }
    
    vec4 c = val / float(patch) * 2.;
    c.a = 1.;
    
    gl_FragColor = c;
}