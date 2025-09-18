varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;

uniform float seed;
uniform float detail;
uniform float phase;
uniform float size;

#define PI 3.14159265359
#define TAU 6.283185307179586

vec2 random2( in vec2 st ) { return fract(sin(phase + vec2(dot(st, vec2(127.1, 311.7)), dot(st, vec2(269.5, 183.3)))) * seed); }
float random( in vec2 st ) { return fract(sin(dot(st, vec2(12.9898, 78.233))) * seed); }

void main() {
	vec4 base = texture2D(gm_BaseTexture, v_vTexcoord);
	float bas = (base.r + base.g + base.b) / 3. * base.a;
	float col = bas;
	
	vec2 tx = floor(v_vTexcoord * dimension);
	vec2 st = floor(tx / detail) * detail;
	vec2 fr = fract(tx / detail);
	
    for (int y = -1; y <= 1; y++)
    for (int x = -1; x <= 1; x++) {
		
        vec2 neighbor = vec2(float(x),float(y));
        vec2 point    = st + detail * neighbor;
		     point   += random2(point) * detail;
		
		vec4 _sam = texture2D(gm_BaseTexture, point / dimension);
		float sam = (_sam.r + _sam.g + _sam.b) / 3. * _sam.a;
		if(sam == .0) continue;
		
		float depth = random(point) * detail * size * sam;
		float dist  = distance(point, tx);
		
		if(dist < depth) col = max(col, sam);
    }
    
	gl_FragColor = vec4(col, col, col, 1.);
	
}