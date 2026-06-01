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
		
		for (int i = 0; i < 256; i++) {
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

float noise3D(vec3 p) {
	return fract(sin(dot(p ,vec3(12.9898,78.233,128.852))) * 43758.5453)*2.0-1.0;
}

float simplex3D(vec3 p) {
	float f3 = 1.0/3.0;
	float s = (p.x+p.y+p.z)*f3;
	int i = int(floor(p.x+s));
	int j = int(floor(p.y+s));
	int k = int(floor(p.z+s));
	
	float g3 = 1.0/6.0;
	float t = float((i+j+k))*g3;
	float x0 = float(i)-t;
	float y0 = float(j)-t;
	float z0 = float(k)-t;
	x0 = p.x-x0;
	y0 = p.y-y0;
	z0 = p.z-z0;
	
	int i1,j1,k1;
	int i2,j2,k2;
	
	if(x0>=y0) {
		if(y0>=z0){ i1=1; j1=0; k1=0; i2=1; j2=1; k2=0; } // X Y Z order
		else if(x0>=z0){ i1=1; j1=0; k1=0; i2=1; j2=0; k2=1; } // X Z Y order
		else { i1=0; j1=0; k1=1; i2=1; j2=0; k2=1; }  // Z X Z order
		
	} else { 
		if(y0<z0) { i1=0; j1=0; k1=1; i2=0; j2=1; k2=1; } // Z Y X order
		else if(x0<z0) { i1=0; j1=1; k1=0; i2=0; j2=1; k2=1; } // Y Z X order
		else { i1=0; j1=1; k1=0; i2=1; j2=1; k2=0; } // Y X Z order
	}
	
	float x1 = x0 - float(i1) + g3; 
	float y1 = y0 - float(j1) + g3;
	float z1 = z0 - float(k1) + g3;
	float x2 = x0 - float(i2) + 2.0*g3; 
	float y2 = y0 - float(j2) + 2.0*g3;
	float z2 = z0 - float(k2) + 2.0*g3;
	float x3 = x0 - 1.0 + 3.0*g3; 
	float y3 = y0 - 1.0 + 3.0*g3;
	float z3 = z0 - 1.0 + 3.0*g3;	
				 
	vec3 ijk0 = vec3(i,j,k);
	vec3 ijk1 = vec3(i+i1,j+j1,k+k1);	
	vec3 ijk2 = vec3(i+i2,j+j2,k+k2);
	vec3 ijk3 = vec3(i+1,j+1,k+1);	
            
	vec3 gr0 = normalize(vec3(noise3D(ijk0),noise3D(ijk0*2.01),noise3D(ijk0*2.02)));
	vec3 gr1 = normalize(vec3(noise3D(ijk1),noise3D(ijk1*2.01),noise3D(ijk1*2.02)));
	vec3 gr2 = normalize(vec3(noise3D(ijk2),noise3D(ijk2*2.01),noise3D(ijk2*2.02)));
	vec3 gr3 = normalize(vec3(noise3D(ijk3),noise3D(ijk3*2.01),noise3D(ijk3*2.02)));
	
	float n0 = 0.0;
	float n1 = 0.0;
	float n2 = 0.0;
	float n3 = 0.0;

	float t0 = 0.5 - x0*x0 - y0*y0 - z0*z0;
	if(t0>=0.0) {
		t0*=t0;
		n0 = t0 * t0 * dot(gr0, vec3(x0, y0, z0));
	}
	float t1 = 0.5 - x1*x1 - y1*y1 - z1*z1;
	if(t1>=0.0) {
		t1*=t1;
		n1 = t1 * t1 * dot(gr1, vec3(x1, y1, z1));
	}
	float t2 = 0.5 - x2*x2 - y2*y2 - z2*z2;
	if(t2>=0.0) {
		t2 *= t2;
		n2 = t2 * t2 * dot(gr2, vec3(x2, y2, z2));
	}
	float t3 = 0.5 - x3*x3 - y3*y3 - z3*z3;
	if(t3>=0.0) {
		t3 *= t3;
		n3 = t3 * t3 * dot(gr3, vec3(x3, y3, z3));
	}
	return 96.0*(n0+n1+n2+n3);
	
}

float perlin ( vec3 pos, int iteration ) {
	float amp = pow(2., float(iteration) - 1.) / (pow(2., float(iteration)) - 1.);
    float n   = 0.;
	
	for(int i = 0; i < iteration; i++) {
		n += (simplex3D(pos) + 1.) / 2. * amp;
		amp *= .5;
		pos *= 2.;
	}
	
	return n;
}

vec4 sample3D(vec3 pos) {
	float p = perlin(pos * perlinScale + perlinPosition, perlinIteration);
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