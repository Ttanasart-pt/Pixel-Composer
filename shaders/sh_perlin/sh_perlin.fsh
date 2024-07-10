varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  u_resolution;
uniform vec2  position;
uniform float scale;
uniform int   iteration;

///////////////////// PERLIN START /////////////////////

float random  (in vec2 st) { return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123); }
vec2  random2 (in vec2 st) { float a = random(st); return vec2(cos(a), sin(a)); }

float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    vec2 u = f * f * (3.0 - 2.0 * f);

	float lerp1 = mix(dot(f - vec2(0.0, 0.0), random2(i + vec2(0.0, 0.0))), dot(f - vec2(1.0, 0.0), random2(i + vec2(1.0, 0.0))), u.x);
    float lerp2 = mix(dot(f - vec2(0.0, 1.0), random2(i + vec2(0.0, 1.0))), dot(f - vec2(1.0, 1.0), random2(i + vec2(1.0, 1.0))), u.x);
    
    return mix(lerp1, lerp2, u.y);
}

float perlin ( vec2 pos, int iteration ) {
	float amp = pow(2., float(iteration) - 1.) / (pow(2., float(iteration)) - 1.);
    float n   = 0.;
	
	for(int i = 0; i < iteration; i++) {
		n += noise(pos) * amp;
		
		amp *= .5;
		pos *= 2.;
	}
	
	return n;
}

///////////////////// PERLIN END /////////////////////

void main() {
    vec2 pos = position + v_vTexcoord * scale;
	float n  = perlin(pos, iteration);
	
    gl_FragColor = vec4(vec3(n), 1.0);
}
