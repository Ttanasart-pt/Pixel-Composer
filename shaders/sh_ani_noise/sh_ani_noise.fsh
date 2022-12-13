//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 noiseAmount;
uniform vec2 position;
uniform float angle;
uniform float seed;

float random (in vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233)) * mod(seed, 32.156) * 12.588) * 43758.5453123);
}

void main() {
	vec2 pos = v_vTexcoord - position, _pos;
	_pos.x = pos.x * cos(angle) - pos.y * sin(angle);
	_pos.y = pos.x * sin(angle) + pos.y * cos(angle);
	
	float yy = floor(_pos.y * noiseAmount.y);
	float xx = (_pos.x + random(vec2(yy))) * noiseAmount.x;
	float x0 = floor(xx);
	float x1 = floor(xx) + 1.;
	
	float noise0 = random(vec2(x0, yy));
	float noise1 = random(vec2(x1, yy));
	
    gl_FragColor = vec4(vec3(mix(noise0, noise1, (xx - x0) / (x1 - x0))), 1.);
}
