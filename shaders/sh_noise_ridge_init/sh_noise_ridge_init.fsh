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
uniform float amplitude;

#define PI  3.141592653589793
#define TAU 6.283185307179586

float hash(float x) { return fract(fract(x * (0.3183098861 + seed / 100000.)) * fract(x * (0.15915494309 + seed / 100000.)) * 265871.1723); }
vec2  hash(vec2 x)  { return fract(fract(x * (0.3183098861 + seed / 100000.)) * fract(x * (0.15915494309 + seed / 100000.)) * 265871.1723); }
float hash2(vec2 x) { return hash(dot(mod(x, 100.0), vec2(127.1, 311.7))); }

vec2 iq_hash( vec2 p ) {
	p = vec2( dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)) );
	return -1.0 + 2.0 * fract(sin(p) * (seed / 100.));
}

float noise( in vec2 p ) {
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

void main() {
	vec2  vtx = getUV(v_vTexcoord);
	vec2  ntx = vtx * vec2(1., dimension.y / dimension.x);
	float ang = radians(rotation);
    vec2  pos = (ntx - position / dimension) * mat2(cos(ang), -sin(ang), sin(ang), cos(ang)) * scale;
	
	float height = noise(pos) * amplitude;
    gl_FragColor = vec4(height, height, height, 1.);
}
