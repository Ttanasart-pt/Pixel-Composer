varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define EPSILON 1e-5
#ifdef _YY_HLSL11_ 
	#define PALETTE_LIMIT 1024 
#else 
	#define PALETTE_LIMIT 256 
#endif

uniform vec2  dimension;
uniform float seed;

uniform int   axis;

uniform int   crossAxis;
uniform float crossPosition;

uniform vec3  perlinPosition;
uniform float perlinScale;
uniform int   perlinIteration;

uniform vec2  renderLevel;

#region ////========== RM ============
	uniform vec3  camRotation;
	uniform float orthoScale;
	
	uniform int   shape;
	uniform vec3  shapeRotation;
	uniform vec3  shapeScale;

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

	float march(vec3 camera, vec3 direction) {
		float depth = 0.;
		
		for (int i = 0; i < 32; i++) {
			vec3  p = camera + depth * direction;
			float dist = 0.;
			
			if(shape == 0) {
				vec3 q = abs(p) - .5;
				dist = length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
			}
			
			if(shape == 1) dist = length(p) - .5;
			
			if (dist < EPSILON) return depth;
			
			depth += dist;
			if (depth >= 10.) return 10.;
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
#endregion

float hash(vec3 p) {
    p  = fract( p * (seed / 1000. + 0.3183099) + .1 );
	p *= 17.0;
    return fract( p.x*p.y*p.z*(p.x+p.y+p.z) );
}

vec3 hash3(vec3 p) {
	p  = fract( p * (seed / 1000. + 0.3183099) + .1 );
	p *= 17.0;
	return fract(vec3(p.x*p.y*p.z*(p.x+p.y+p.z),
					  p.x*p.y*p.z*(p.x+p.y+p.z+1.),
					  p.x*p.y*p.z*(p.x+p.y+p.z+2.)));
}

float cell( in vec3 x ) {
    vec3 i_st = floor(x);
    vec3 f_st = fract(x);
    float m_dist = 1.;
	
    for (int z = -1; z <= 1; z++)
    for (int y = -1; y <= 1; y++)
    for (int x = -1; x <= 1; x++) {
        vec3 neighbor = vec3(float(x),float(y),float(z));
        vec3 point    = hash3(i_st + neighbor);
		
        vec3 _diff = neighbor + point - f_st;
        float dist = length(_diff);
        m_dist = min(m_dist, dist);
    }
	
	return m_dist;
}

float cellular( vec3 pos, int iteration ) {
	float amp = pow(2., float(iteration) - 1.) / (pow(2., float(iteration)) - 1.);
    float n   = 0.;
	
	for(int i = 0; i < iteration; i++) {
		n += cell(pos) * amp;
		amp *= .5;
		pos *= 2.;
	}
	
	return n;
}

vec4 sample3D(vec3 pos) {
	float p = cellular(pos * perlinScale + perlinPosition, perlinIteration);
	p = (p - renderLevel.x) / (renderLevel.y - renderLevel.x);
	return vec4(p,p,p,1.);
}
	
void main() {
	mat3 rx = rotateX(shapeRotation.x);
	mat3 ry = rotateY(shapeRotation.y);
	mat3 rz = rotateZ(shapeRotation.z);
	mat3 objRotMatrix = rx * ry * rz;

	float depth;
	vec3  hitPos = scene(v_vTexcoord, camRotation, depth);
	bool  hit    = depth < 10.;
	
	if(axis == 0) hitPos.xyz = hitPos.xyz;
	if(axis == 1) hitPos.xyz = hitPos.yzx;
	if(axis == 2) hitPos.xyz = hitPos.zxy;
	hitPos = objRotMatrix * hitPos * shapeScale;
	
	gl_FragData[0] = vec4(sample3D(hitPos).rgb, hit? 1. : 0.);
	
	vec3 crossPos = vec3(0.);
	if(crossAxis == 0) crossPos = vec3(crossPosition, v_vTexcoord.x, v_vTexcoord.y);
	if(crossAxis == 1) crossPos = vec3(v_vTexcoord.x, crossPosition, v_vTexcoord.y);
	if(crossAxis == 2) crossPos = vec3(v_vTexcoord.x, v_vTexcoord.y, crossPosition);
	crossPos = objRotMatrix * crossPos * shapeScale;
	
	gl_FragData[1] = sample3D(crossPos);
	
}