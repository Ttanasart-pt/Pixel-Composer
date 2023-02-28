//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  position;
uniform vec2  u_resolution;
uniform vec2  scale;
uniform int   iteration;
uniform float seed;
uniform int   tile;

float random (in vec2 st, float seed) {
    return fract(sin(dot(st.xy + vec2(21.4564, 46.8564), vec2(12.9898, 78.233))) * (43758.5453123 + seed));
}

float noise (in vec2 st, in vec2 scale) {
    vec2 cellMin = tile == 1? mod(floor(st),                scale) : floor(st);
    vec2 cellMax = tile == 1? mod(floor(st) + vec2(1., 1.), scale) : floor(st) + vec2(1., 1.);
	vec2 f = fract(st);
	
    // Four corners in 2D of a tile
	float sedSt = floor(seed);
	float sedFr = fract(seed);
	
    float a = mix(random(vec2(cellMin.x, cellMin.y), sedSt), random(vec2(cellMin.x, cellMin.y), sedSt + 1.), sedFr);
    float b = mix(random(vec2(cellMax.x, cellMin.y), sedSt), random(vec2(cellMax.x, cellMin.y), sedSt + 1.), sedFr);
    float c = mix(random(vec2(cellMin.x, cellMax.y), sedSt), random(vec2(cellMin.x, cellMax.y), sedSt + 1.), sedFr);
    float d = mix(random(vec2(cellMax.x, cellMax.y), sedSt), random(vec2(cellMax.x, cellMax.y), sedSt + 1.), sedFr);

    // Cubic Hermine Curve.  Same as SmoothStep()
    vec2 u = f * f * (3.0 - 2.0 * f);

    // Mix 4 coorners percentages
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

void main() {
    vec2  pos = (v_vTexcoord + position) * scale;
	float amp = pow(2., float(iteration) - 1.)  / (pow(2., float(iteration)) - 1.);
    float n = 0.;
	vec2  sc = scale;
	
	for(int i = 0; i < iteration; i++) {
		n += noise(pos, sc) * amp;
		
		sc  *= 2.;
		amp *= .5;
		pos *= 2.;
	}
	
    gl_FragColor = vec4(vec3(n), 1.0);
}
