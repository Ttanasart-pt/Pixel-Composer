varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define EPSILON 1e-5

uniform int   MAX_MARCHING_STEPS;

uniform vec2  dimension;

uniform int   axis;
uniform vec3  camRotation;
uniform float orthoScale;

#ifdef _YY_HLSL11_ 
	#define PALETTE_LIMIT 1024 
#else 
	#define PALETTE_LIMIT 256 
#endif
uniform vec4  palette[PALETTE_LIMIT];
uniform int   paletteAmount;

#region ////========== Transform ============
	mat3 rotateX(float dg) {
		float c = cos(radians(dg));
		float s = sin(radians(dg));
		return mat3(
			vec3(1, 0,  0),
			vec3(0, c, -s),
			vec3(0, s,  c)
		);
	}
	
	mat3 rotateY(float dg) {
		float c = cos(radians(dg));
		float s = sin(radians(dg));
		return mat3(
			vec3( c, 0, s),
			vec3( 0, 1, 0),
			vec3(-s, 0, c)
		);
	}
	
	mat3 rotateZ(float dg) {
		float c = cos(radians(dg));
		float s = sin(radians(dg));
		return mat3(
			vec3(c, -s, 0),
			vec3(s,  c, 0),
			vec3(0,  0, 1)
		);
	}
	
	mat3 inverse(mat3 m) {
		float a00 = m[0][0], a01 = m[0][1], a02 = m[0][2];
		float a10 = m[1][0], a11 = m[1][1], a12 = m[1][2];
		float a20 = m[2][0], a21 = m[2][1], a22 = m[2][2];
		
		float b01 =  a22 * a11 - a12 * a21;
		float b11 = -a22 * a10 + a12 * a20;
		float b21 =  a21 * a10 - a11 * a20;
		
		float det = a00 * b01 + a01 * b11 + a02 * b21;
		
		return mat3(b01, (-a22 * a01 + a02 * a21), ( a12 * a01 - a02 * a11),
				    b11, ( a22 * a00 - a02 * a20), (-a12 * a00 + a02 * a10),
				    b21, (-a21 * a00 + a01 * a20), ( a11 * a00 - a01 * a10)) / det;
	}
#endregion

float SDF(vec3 p) {
	vec3 q = abs(p) - .5;
	return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float march(vec3 camera, vec3 direction) {
	float depth = 0.;
	
	for (int i = 0; i < 100; i++) {
		float dist = SDF(camera + depth * direction);
		if (dist < EPSILON)  
			return depth;
		
		depth += dist;
		if (depth >= 10.)
			return 10.;
	}
	
	return 10.;  
}

vec3 scene(vec2 tx, vec3 camRotation, out float outDepth) {
	mat3 rx = rotateX(camRotation.x);
	mat3 ry = rotateY(camRotation.y);
	mat3 rz = rotateZ(camRotation.z);

	mat3 camRotMatrix  = rx * ry * rz;
	mat3 camIrotMatrix = inverse(camRotMatrix);
	
	vec3 dir = vec3(0., 0., -1.);
	vec3 eye = vec3((tx - .5) * 2. * orthoScale, 5.);
	
	dir  = camIrotMatrix * dir;
	eye  = camIrotMatrix * eye;

	outDepth = march(eye, dir);
	vec3 hitPos = eye + dir * outDepth;
	
	return hitPos;
}
	
void main() {
	float depth;
	vec3  hitPos = scene(v_vTexcoord, camRotation, depth) + .5;
	bool  hit    = depth < 10.;
	float amo    = float(paletteAmount);
	
	vec4 c000 = palette[int(mod(0., amo))];
	vec4 c001 = palette[int(mod(1., amo))];
	
	vec4 c010 = palette[int(mod(2., amo))];
	vec4 c011 = palette[int(mod(3., amo))];
	
	vec4 c100 = palette[int(mod(4., amo))];
	vec4 c101 = palette[int(mod(5., amo))];

	vec4 c110 = palette[int(mod(6., amo))];
	vec4 c111 = palette[int(mod(7., amo))];
	
	if(axis == 0) hitPos.xyz = hitPos.xyz;
	if(axis == 1) hitPos.xyz = hitPos.yzx;
	if(axis == 2) hitPos.xyz = hitPos.zxy;
	
	vec4 c00 = mix(c000, c001, hitPos.z);
	vec4 c01 = mix(c010, c011, hitPos.z);

	vec4 c10 = mix(c100, c101, hitPos.z);
	vec4 c11 = mix(c110, c111, hitPos.z);

	vec4 c0 = mix(c00, c01, hitPos.y);
	vec4 c1 = mix(c10, c11, hitPos.y);

	vec4 c = mix(c0, c1, hitPos.x);
	
	gl_FragColor = vec4(c.rgb,  hit? 1. : 0.);
}