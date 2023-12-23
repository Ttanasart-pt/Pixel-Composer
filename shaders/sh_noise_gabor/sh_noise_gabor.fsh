// Gabor noise
// By shader god Inigo Quilez (https://iquilezles.org)
// MIT License

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float seed;

uniform float alignment;

uniform float sharpness;

uniform float rotation;

uniform vec2  u_resolution;
uniform vec2  position;

uniform vec2  scale;

uniform vec2  augment;

vec2 hash(vec2 p) { return fract(sin(vec2(
										dot(p, vec2(127.1324, 311.7874)) * (152.6178612 + seed / 10000.), 
										dot(p, vec2(269.8355, 183.3961)) * (437.5453123 + seed / 10000.)
									)) * 43758.5453); }

vec3 gabor_wave(in vec2 p) { 
    vec2  ip = floor(p);
    vec2  fp = fract(p);
    
    float fa = sharpness;
	float fr = alignment * 6.283185;
    float rt = radians(rotation);
	
    vec3 av = vec3(0.0, 0.0, 0.0);
    vec3 at = vec3(0.0, 0.0, 0.0);
	
	for( int j = -2; j <= 2; j++ )
    for( int i = -2; i <= 2; i++ ) {		
        vec2  o = vec2( i, j );
        vec2  h = hash(ip + o);
        vec2  r = fp - (o + h);

        vec2  k = normalize(-1.0 + 2.0 * hash(ip + o + augment) );
		
        float d = dot(r, r);
        float l = dot(r, k) + rt;
        float w = exp(-fa * d);
        vec2 cs = vec2( cos(fr * l + rt), sin(fr * l + rt) );
        
        av += w * vec3(cs.x, -2.0 * fa * r * cs.x - cs.y * fr * k );
        at += w * vec3(1.0,  -2.0 * fa * r);
	}
  
    return vec3( av.x, av.yz - av.x * at.yz / at.x  ) / at.x;
}

void main() {
	vec2 pos    = v_vTexcoord;
	     pos.x *= (u_resolution.x / u_resolution.y);
         pos    = (pos + position) * scale;
	
	vec3 f   = gabor_wave(pos);
	vec3 col = vec3(0.5 + 0.5 * f.x);
	
    gl_FragColor = vec4( col, 1.0 );
}