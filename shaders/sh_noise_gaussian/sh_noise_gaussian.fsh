varying vec2 v_vTexcoord;
varying vec4 v_vColour;

const float PI = 3.14159265358979323846;

uniform vec2 dimension;

uniform float seed;
uniform float mean;
uniform float varience;

uniform vec2  position;
uniform float rotation;
uniform vec2  scale;

uniform vec2  level;

uniform int       convertMode;
uniform sampler2D convertSurface1;
uniform sampler2D convertSurface2;

float noise(vec2 p) { return fract(sin(dot(p, vec2(78.233,128.852))) * (43758.5453 + seed / 10000.)); }

void main() {
	vec2  tx  = 1. / dimension;
	float ang = radians(rotation);
	mat2  rot = mat2(cos(ang), - sin(ang), sin(ang), cos(ang));
	
	vec2 sx = (v_vTexcoord * rot) * scale - position;
	float n1, n2;
	
	if(convertMode == 0) {
		n1 = noise(sx + vec2(3.9613, 1.6452)); n1 = max(n1, 0.001);
		n2 = noise(sx + vec2(0.1654, 2.9873));
		
	} else if(convertMode == 1) {
		n1 = texture2D( convertSurface1, sx ).r;
		n2 = texture2D( convertSurface2, sx ).r;
		
	}
	
	float z0 = sqrt(-2. * log(n1)) * cos(2. * PI * n2);
	float z1 = sqrt(-2. * log(n1)) * sin(2. * PI * n2);
	
	z0 = mean + z0 * varience;
	z0 = (z0 - level.x) / (level.y - level.x);
	gl_FragColor = vec4(z0, z0, z0, 1.);
}