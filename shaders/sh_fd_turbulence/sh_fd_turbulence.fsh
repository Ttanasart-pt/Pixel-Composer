#define PI 3.14159265359

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float scale;
uniform float strength;
uniform float seed;

float random (in vec2 st, float _seed) { return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * (43758.5453123 + (seed + _seed))); }

float noise (in vec2 st, float _seed) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i, _seed);
    float b = random(i + vec2(1.0, 0.0), _seed);
    float c = random(i + vec2(0.0, 1.0), _seed);
    float d = random(i + vec2(1.0, 1.0), _seed);

    // Cubic Hermine Curve.  Same as SmoothStep()
    vec2 u = f * f * (3.0 - 2.0 * f);

    // Mix 4 coorners percentages
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

void main() {
	float sX = noise(v_vTexcoord * scale, 1.986458) * 2. - 1.;
	float sY = noise(v_vTexcoord * scale, 5.648630) * 2. - 1.;
	
	gl_FragColor = vec4(sX * strength, sY * strength, 0., 1.);
}
