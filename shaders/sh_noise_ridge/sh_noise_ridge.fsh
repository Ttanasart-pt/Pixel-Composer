#pragma use(uv)

#region -- uv -- [1770002023.9166503]
    uniform sampler2D uvMap;
    uniform int   useUvMap;
    uniform float uvMapMix;

    vec2 getUV(in vec2 uv) {
        if(useUvMap == 0) return uv;

        vec2 vuv   = texture2D( uvMap, uv ).xy;
             vuv.y = 1.0 - vuv.y;

        vec2 vtx = mix(uv, vuv, uvMapMix);
        return vtx;
    }
#endregion -- uv --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec2  position;
uniform float rotation;
uniform vec2  scale;
uniform float seed;

uniform int   mode;
uniform int   iteration;

const float PI = 3.14159265358979323846;

float hash(float x) { return fract(fract(x * (0.3183098861 + seed / 100000.)) * fract(x * (0.15915494309 + seed / 100000.)) * 265871.1723); }
vec3  hash(vec3 x)  { return fract(fract(x * (0.3183098861 + seed / 100000.)) * fract(x * (0.15915494309 + seed / 100000.)) * 265871.1723); }

float hash2(vec2 x) { return hash(dot(mod(x, 100.0), vec2(127.1, 311.7))); }
vec3  hash3x2(vec2 x1,vec2 x2,vec2 x3) { return hash(vec3(dot(mod(x1, 100.0), vec2(127.1, 311.7)), 
                                                          dot(mod(x2, 100.0), vec2(127.1, 311.7)), 
                                                          dot(mod(x3, 100.0), vec2(127.1, 311.7)) )); }

vec4 hash4( vec4 n ) { return fract(sin(n) * (753.5453123 + seed / 100000.)); }

vec2 iq_hash( vec2 p ) {
	p = vec2( dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)) );
	return -1.0 + 2.0 * fract(sin(p) * (seed / 100.));
}

float iq_noise( in vec2 p ) {
    const float K1 = 0.366025404; // (sqrt(3)-1)/2;
    const float K2 = 0.211324865; // (3-sqrt(3))/6;
	
	vec2  i = floor( p + (p.x + p.y) * K1 );
	vec2  a = p - i + (i.x + i.y) * K2;
    float m = step(a.y, a.x); 
    vec2  o = vec2(m, 1.0 - m);
    vec2  b = a - o + K2;
	vec2  c = a - 1.0 + 2.0 * K2;
	
    vec3  h = max( 0.5 - vec3(dot(a, a), dot(b, b), dot(c, c) ), 0.0 );
	vec3  n = h * h * h * h * vec3( dot(a, iq_hash(i + 0.0)), dot(b, iq_hash(i + o)), dot(c, iq_hash(i + 1.0)));
    return dot( n, vec3(70.0) ) * .7 + .6;
}

float strip(in vec2 p, in vec2 o, in float r, in float s) {
	vec2 d = (p - o) * mat2(cos(r), -sin(r), sin(r), cos(r));
	return .5 + .5 * sin(d.y * s) ;
}

float ridgeNoise( vec2 pos, vec2 sca ) {
	vec2 ppos = pos * sca;
	
	float height = iq_noise(ppos);
	vec2  grad   = vec2( iq_noise(ppos + vec2(0., 1.)) - iq_noise(ppos + vec2(0., -1.)),
		                 iq_noise(ppos + vec2(1., 0.)) - iq_noise(ppos + vec2(-1., 0.)) );
	
	float dir = atan(grad.x, grad.y);
	float dis = length(grad);
	
	float str = strip(ppos, vec2(.5), dir, 8.);
	str *= height;
	
	return str;
} 

vec3 iterateNoise( vec2 pos, int iteration ) {
	float amp = 1.;
    float n   = 0.;
    vec2  sca = scale;
	
	for(int i = 0; i < iteration; i++) {
		n = max(n, ridgeNoise(pos, sca) * amp);
    
		amp *= .5;
		pos *= 2.;
	}
	
	return vec3(n, n, n);
}

void main() {
	vec2  vtx = getUV(v_vTexcoord);
	vec2  ntx = vtx * vec2(1., dimension.y / dimension.x);
	float ang = radians(rotation);
    vec2  pos = (ntx - position / dimension) * mat2(cos(ang), -sin(ang), sin(ang), cos(ang));
	vec3  col = iterateNoise(pos, iteration);
	
    gl_FragColor = vec4(col, 1.);
}
