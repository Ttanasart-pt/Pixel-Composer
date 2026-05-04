varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define PI 3.1415926535897932384626433832795
#define TAU 6.283185307179586476925286766559

uniform int shapeIndex;

uniform float innerRad;
uniform vec2  origin;
uniform float rotation;

uniform int useTexture;
uniform sampler2D texture;

uniform int   discardBlack;

uniform float spiralSize;
uniform float spiralPhase;
uniform float spiralIntensity;
uniform float spiralRotation;
uniform int   spiralMultiply;

uniform float lineShape[33];

uniform vec2 level;
uniform vec2 textureRange;

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
	
	float scl = 2.;
	vec2  sc;
	bool  doSpiral = true;
	
	if(useTexture == 1) {
		vec4 tex = texture2D( texture, v_vTexcoord );
		scl /= tex.r;
	}
	
	if(shapeIndex == 0 || shapeIndex == 1) {
		vec2 tx = (v_vTexcoord - .5) * scl;
		
		float r = length(tx);
		if(r > 1.) discard;
		
		float nxy = 1.0 - (pow(origin.x, 2.0) + pow(origin.y, 2.0));
		// if(nxy < 0.) discard;
		
		float nz     = sqrt(abs(nxy)) * sign(nxy);
		vec3  normal = vec3(origin, nz);
		
		sc = sphereCoord(tx, normalize(normal));
		
	} else if(shapeIndex == 2 || shapeIndex == 3) {
		doSpiral = false;
		
		float _x = v_vTexcoord.x;
		float _y = v_vTexcoord.y;
		
		_x = mix(textureRange[0], textureRange[1], _x);
		int   ix = int(floor(_x * 32.));
		float mx = fract(_x * 32.);
		
		float thk = mix(lineShape[ix], lineShape[ix + 1], mx);
		if(abs(_y - .5) > thk) 
			discard;
		
		sc = vec2(0., (1. - _x) / 4.);
	}
	
	float li = sc.x; // angle
	float lo = sc.y; // distance
	
	if(doSpiral && spiralSize != 0.) {
		float spir = spiralSize;
		float spra = fract((spiralPhase + lo + spiralRotation / 360.) * spir);
		
		float spiralDist = 1. - min(abs(li - spra), 1. - abs(li - spra));
		lo = mix(lo, spiralMultiply == 1? lo * spiralDist : spiralDist, spiralIntensity);
	}
	
	float i  = step(innerRad, lo);
	float g  = i * lo * 4.;
	
	if(g <= 0.) { gl_FragColor = vec4(0., 1., 0., 1.); return; }
	
	g = 1. - g;
	g = (g - level[0]) / (level[1] - level[0]);
	gl_FragColor = vec4(g * v_vColour.a, 0., 0., v_vColour.a);
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