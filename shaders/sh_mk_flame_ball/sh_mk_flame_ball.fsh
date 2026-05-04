varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define PI 3.1415926535897932384626433832795
#define TAU 6.283185307179586476925286766559

uniform float innerRad;
uniform vec2  origin;

// Sphere coordinate [(0,TAU), (0,1)]
vec2 sphereCoord(vec2 uv, vec3 normal) {
	// position at [0,0,1] normal
	float dis = length(uv);
	float diy = sqrt(1. - pow(dis, 2.));
	vec3 pos = vec3(uv, diy);

	// rotate to normal
	vec3 axis = cross(vec3(0., 0., 1.), normal);
	float angle = acos(dot(vec3(0., 0., 1.), normal));
	float s = sin(angle);
	float c = cos(angle);
	vec3 rotPos = pos * c + cross(axis, pos) * s + axis * dot(axis, pos) * (1. - c);

	// convert to sphere coord
	float theta = atan(rotPos.y, rotPos.x);
	if(theta < 0.) theta += TAU;
	float phi = acos(rotPos.z);
	return vec2(theta / TAU, phi / TAU);
}

void main() {
	vec2 tx = (v_vTexcoord - .5) * 2.;
	float r = length(tx);
	if(r > 1.) discard;
	
	float nz = sqrt(1.0 - (pow(origin.x, 2.0) + pow(origin.y, 2.0)));
	vec3 normal = vec3(origin, nz);

	vec2 sc = sphereCoord(tx, normalize(normal));

	float lo = sc.y;
	// gl_FragColor = vec4(vec3(lo), 1.); return;
	
	float i  = step(innerRad, lo);
	float g  = i * lo * 4.;
	float a  = step(0., g);
	
	gl_FragColor = vec4(vec3(g), a);
}

/* 2d version idk which one look nicer
vec2  tx = v_vTexcoord - .5;
float lo = length(tx);
float o  = step(lo, .5);

vec2 itx = v_vTexcoord - vec2(.25, .5);
float li = length(itx);
float i  = step(li / innerRad, .5);

float g = o * lo * 2. - i;
float a = o - i;

if(a <= 0.) discard;
gl_FragColor = vec4(vec3(g), a);
*/