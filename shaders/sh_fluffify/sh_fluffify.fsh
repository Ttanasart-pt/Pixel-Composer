varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;

uniform int   shape;
uniform float seed;
uniform float detail;
uniform float phase;

uniform vec2      size;
uniform int       sizeUseSurf;
uniform sampler2D sizeSurf;
uniform float     sizeMultiply;

uniform float iteration;
uniform float maxIteration;

uniform int blend;
uniform int fadeDistance;
uniform int fadeIteration;

#define PI 3.14159265359
#define TAU 6.283185307179586

vec2 random2( in vec2 st ) { return fract(sin(phase + vec2(dot(st, vec2(127.1, 311.7)), dot(st, vec2(269.5, 183.3)))) * seed); }
float random( in vec2 st ) { return fract(sin(dot(st, vec2(12.9898, 78.233))) * seed); }

void main() {
	float str = size.x;
	if(sizeUseSurf == 1) {
		vec4 _vMap = texture2D( sizeSurf, v_vTexcoord );
		str = mix(size.x, size.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	str *= sizeMultiply;
	
	vec4 base = texture2D(gm_BaseTexture, v_vTexcoord);
	float bas = (base.r + base.g + base.b) / 3. * base.a;
	float col = bas;
	
	vec2 tx = floor(v_vTexcoord * dimension);
	vec2 st = floor(tx / detail) * detail;
	vec2 fr = fract(tx / detail);
	
	float min_dist = 99999.;
	
    for (int y = -1; y <= 1; y++)
    for (int x = -1; x <= 1; x++) {
		
        vec2 neighbor = vec2(float(x),float(y));
        vec2 point    = st + detail * neighbor;
		     point   += random2(point) * detail;
		
		vec4 _sam = texture2D(gm_BaseTexture, point / dimension);
		float sam = (_sam.r + _sam.g + _sam.b) / 3. * _sam.a;
		if(sam == .0) continue;
		
		float depth = random(point) * detail * str * sam;
		float dist  = 0.;
		vec2  dx = point - tx;
		
		     if(shape == 0) dist = length(dx);
		else if(shape == 1) dist = abs(dx.x) + abs(dx.y);
		else if(shape == 2) dist = max(abs(dx.x), abs(dx.y));
		
		if(dist >= depth) continue;
		
		// if(fadeDistance == 1) sam *= 1. - dist / depth;
		
		if(dist < min_dist) {
			if(blend == 1) col = sam;
			min_dist = dist;
		}
		
		if(blend == 0) col = max(col, sam);
    }
    
    if(fadeIteration == 1) col = bas + (col - bas) * clamp(iteration / maxIteration, 0., 1.);
	gl_FragColor = vec4(col, col, col, 1.);
	
}