#define PI    3.1415972
#define SQRT2 0.70710678118

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform int   patch;
uniform int   reconstruct;

float DCTcoeff(vec2 k, vec2 x) { return cos(PI * k.x * x.x) * cos(PI * k.y * x.y); }

void main() {
    vec2 tx = dimension * v_vTexcoord;
    
    vec2 k = mod(tx, float(patch)) - .5;
    vec2 K = floor(tx - k);
    
    vec4 val = vec4(0.);
    for(int u = 0; u < reconstruct; ++u)
	for(int v = 0; v < reconstruct; ++v) {
	    
	    vec4  s = texture2D( gm_BaseTexture, (K + vec2(u, v) + .5) / dimension);
	    float c = DCTcoeff(vec2(u, v), (k + .5) / float(patch));
	    c *= u == 0? SQRT2 : 1.;
	    c *= v == 0? SQRT2 : 1.;
	    
        val += s * c;
    }
    
    vec4 c = val / float(patch) * 2.;
    c.a = 1.;
    
    gl_FragColor = c;
}