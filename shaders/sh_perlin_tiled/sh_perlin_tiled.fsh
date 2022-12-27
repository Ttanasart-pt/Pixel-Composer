//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  position;
uniform vec2  u_resolution;
uniform vec2  scale;
uniform float bright;
uniform int   iteration;
uniform float seed;

vec2 modulo(in vec2 divident, in vec2 divisor) {
	divident.x = mod(divident.x, divisor.x);
	divident.y = mod(divident.y, divisor.y);
    return divident;
}

float random (in vec2 st, float seed) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * (43758.5453123 + seed));
}

float noise (in vec2 st) {
    vec2 cellMin = modulo(floor(st),				scale);
    vec2 cellMax = modulo(floor(st) + vec2(1., 1.), scale);
	
	vec2 f = fract(st);
	
    // Four corners in 2D of a tile
    float a = random(vec2(cellMin.x, cellMin.y), seed);
    float b = random(vec2(cellMax.x, cellMin.y), seed);
    float c = random(vec2(cellMin.x, cellMax.y), seed);
    float d = random(vec2(cellMax.x, cellMax.y), seed);

    // Cubic Hermine Curve.  Same as SmoothStep()
    vec2 u = f * f * (3.0 - 2.0 * f);

    // Mix 4 coorners percentages
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

void main() {
    vec2 st = v_vTexcoord + position;
    vec2 pos = st * scale;
	float amp = bright;
    float n = 0.;
	
	for(int i = 0; i < iteration; i++) {
		n += noise(pos) * amp;
		
		amp *= .5;
		pos *= 2.;
	}
	

    gl_FragColor = vec4(vec3(n), 1.0);
}
