#pragma use(uv)

#region -- uv -- [1765685937.0825768]
    uniform sampler2D uvMap;
    uniform int   useUvMap;
    uniform float uvMapMix;

    vec2 getUV(in vec2 uv) {
        if(useUvMap == 0) return uv;

        vec2 vtx = mix(uv, texture2D( uvMap, uv ).xy, uvMapMix);
        vtx.y = 1.0 - vtx.y;
        return vtx;
    }
#endregion -- uv --

//Honeycomb Noise by foxes
//https://www.shadertoy.com/view/ltsSW7

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec2  position;
uniform float rotation;
uniform vec2  scale;
uniform float seed;

uniform int   mode;
uniform int   iteration;

float hash(float x) { return fract(fract(x * (0.3183098861 + seed / 100000.)) * fract(x * (0.15915494309 + seed / 100000.)) * 265871.1723); }
vec3  hash(vec3 x)  { return fract(fract(x * (0.3183098861 + seed / 100000.)) * fract(x * (0.15915494309 + seed / 100000.)) * 265871.1723); }

float hash2(vec2 x) { return hash(dot(mod(x, 100.0), vec2(127.1, 311.7))); }
vec3  hash3x2(vec2 x1,vec2 x2,vec2 x3) { return hash(vec3(dot(mod(x1, 100.0), vec2(127.1, 311.7)), 
                                                          dot(mod(x2, 100.0), vec2(127.1, 311.7)), 
                                                          dot(mod(x3, 100.0), vec2(127.1, 311.7)) )); }

vec4 hash4( vec4 n ) { return fract(sin(n) * (753.5453123 + seed / 100000.)); }

float noiseHoneycomb(vec2 i) {
    vec2 c3;
    i.x *= 1.15470053837925;
    c3.x = floor(i.x) + 1.0;
    
    vec2 b = vec2(i.y + i.x * 0.5, i.y - i.x * 0.5);
    c3.y   = floor(b.x) + floor(b.y);
    vec3 o = fract(vec3(i.x, b.xy));
    
    vec4 s;
    vec3 m1 = hash3x2(c3 + vec2(1.0, 0.0), c3 + vec2(-1.0, -1.0), c3 + vec2(-1.0, 1.0));
    vec3 m2 = hash3x2(c3, c3 + vec2(0.0, 1.0), c3 + vec2(0.0, -1.0));
    vec3 m3 = hash3x2(c3 + vec2(-1.0, 0.0), c3 + vec2(1.0, 1.0), c3 + vec2(1.0, -1.0));
    vec3 m4 = vec3(m2.x, m2.z, m2.y);
    
    vec3 w1 = vec3(o.x, (1.0 - o.y), o.z);
    vec3 w2 = vec3((1.0 - o.x), o.y, (1.0 - o.z));
    
    vec2 d = fract(c3 * 0.5) * 2.0;
    
    s = fract(vec4(dot(m1, w1), dot(m2, w2), dot(m3, w2), dot(m4, w1)));
	
	float f = fract(mix(mix(s.z, s.w, d.x), mix(s.x, s.y, d.x), d.y));
    return f;
}

float noiseHoneycombStar(vec2 i) {
    vec2 c3;
    i.x   *= 1.154700538379251;
    c3.x   = floor(i.x) + 1.0;
    vec2 b = vec2(i.y + i.x * 0.5, i.y - i.x * 0.5);
    c3.y   = floor(b.x) + floor(b.y);
    vec3 o = fract(vec3(i.x, b.xy));
    
    vec4 s;
    vec3 m1 = vec3(hash2(c3 + vec2( 1.0, 0.0)), hash2(c3 + vec2(-1.0, -1.0)), hash2(c3 + vec2(-1.0,  1.0)));
    vec3 m2 = vec3(hash2(c3),                   hash2(c3 + vec2( 0.0,  1.0)), hash2(c3 + vec2( 0.0, -1.0)));
    vec3 m3 = vec3(hash2(c3 + vec2(-1.0, 0.0)), hash2(c3 + vec2( 1.0,  1.0)), hash2(c3 + vec2( 1.0, -1.0)));
    vec3 m4 = vec3(m2.x, m2.z, m2.y);
    
    vec3 w1 = vec3(o.x, (1.0 - o.y), o.z);
    vec3 w2 = vec3((1.0 - o.x), o.y, (1.0 - o.z));
    w1 = w1 * w1 * (3.0 - 2.0 * w1);
    w2 = w2 * w2 * (3.0 - 2.0 * w2);

    vec2 d = fract(c3 * 0.5) * 2.0;
    
    s = fract(vec4(dot(m1, w1), dot(m2, w2), dot(m3, w2), dot(m4, w1)));

	float f = fract(mix(mix(s.z, s.w, d.x), mix(s.x, s.y, d.x), d.y));
    return f;
}

vec3 iterateNoise ( vec2 pos, int iteration ) {
	float amp = pow(2., float(iteration) - 1.) / (pow(2., float(iteration)) - 1.);
    float n   = 0.;
	
	for(int i = 0; i < iteration; i++) {
		     if(mode == 0) n += noiseHoneycomb(pos)     * amp;
        else if(mode == 1) n += noiseHoneycombStar(pos) * amp;
    
		amp *= .5;
		pos *= 2.;
	}
	
	return vec3(n, n, n);
}

void main() {
	vec2  vtx = getUV(v_vTexcoord);
	vec2  ntx = vtx * vec2(1., dimension.y / dimension.x);
	float ang = radians(rotation);
    vec2  pos = (ntx - position / dimension) * mat2(cos(ang), -sin(ang), sin(ang), cos(ang)) * scale * 4.;
	vec3  col = iterateNoise(pos, iteration);
	
	   //  if(mode == 0) col = vec3(noiseHoneycomb(pos));
    // else if(mode == 1) col = vec3(noiseHoneycombStar(pos));
	
    gl_FragColor = vec4(col, 1.);
}
