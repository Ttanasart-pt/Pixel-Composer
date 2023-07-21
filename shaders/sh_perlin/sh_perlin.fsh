//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  u_resolution;
uniform vec2  position;
uniform float scale;
uniform float bright;
uniform int   iteration;

float random (in vec2 st) { return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123); }

float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // Cubic Hermine Curve.  Same as SmoothStep()
    vec2 u = f * f * (3.0 - 2.0 * f);

    // Mix 4 coorners percentages
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

void main() {
    vec2 pos = position + v_vTexcoord * scale;
	float amp = pow(2., float(iteration) - 1.)  / (pow(2., float(iteration)) - 1.);
    float n = 0.;
	
	for(int i = 0; i < iteration; i++) {
		n += noise(pos) * amp;
		
		amp *= .5;
		pos *= 2.;
	}
	
    gl_FragColor = vec4(vec3(n), 1.0);
}
