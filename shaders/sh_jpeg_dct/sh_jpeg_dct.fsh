#define PI    3.1415972
#define SQRT2 0.70710678118

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform int   patch;
uniform float compression;

float DCTcoeff(vec2 k, vec2 x) { return cos(PI * k.x * x.x) * cos(PI * k.y * x.y); }

float round(float val) { return fract(val) > 0.5? ceil(val) : floor(val); }
vec4  round(vec4  val) { return vec4(round(val.x), round(val.y), round(val.z), round(val.w)); }

void main() {
    vec2 tx = dimension * v_vTexcoord;
    
    vec2 k = mod(tx, float(patch)) - .5;
    vec2 K = floor(tx - k);
    
    vec4 val = vec4(0.);
    
    for(int x = 0; x < patch; ++x)
	for(int y = 0; y < patch; ++y) {
	    vec4  s = texture2D( gm_BaseTexture, (K + vec2(x, y) + .5) / dimension);
	    float c = DCTcoeff(k, (vec2(x, y) + .5) / float(patch));
	    c *= k.x < .5? SQRT2 : 1.;
	    c *= k.y < .5? SQRT2 : 1.;
	    
        val += s * c;
	}
        
    vec4 c = val / float(patch) * 2.;
    if(compression != 0.)
        c = round(c / float(patch) * compression) / compression * float(patch);
    c.a = 1.;
    
    gl_FragColor = c;
}