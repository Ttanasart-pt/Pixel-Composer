//Inigo Quilez 
//Oh where would I be without you.

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

const int MAX_MARCHING_STEPS = 512;
const float EPSILON = 1e-5;
const float PI = 3.14159265358979323846;

const float SUBTEXTURE_SIZE = 1024.;
const float TEXTURE_N = 8192. / SUBTEXTURE_SIZE;
const float TEXTURE_S = TEXTURE_N * TEXTURE_N;
const float TEXTURE_T = SUBTEXTURE_SIZE / 8192.;

uniform sampler2D texture0;
uniform sampler2D texture1;
uniform sampler2D texture2;
uniform sampler2D texture3;

uniform float time;

uniform int   shape;
uniform vec3  size;
uniform float radius;
uniform float thickness;
uniform float crop;
uniform float angle;
uniform float height;
uniform vec2  radRange;
uniform float sizeUni;
uniform vec3  elongate;
uniform float rounded;

uniform vec3 waveAmp;
uniform vec3 waveInt;
uniform vec3 waveShift;

uniform int   twistAxis;
uniform float twistAmount;

uniform vec3  position;
uniform vec3  rotation;
uniform float objectScale;

uniform int   ortho;
uniform float fov;
uniform float orthoScale;
uniform vec2  viewRange;
uniform float depthInt;
uniform vec3  tileSize;
uniform vec3  tileAmount;

uniform int  drawBg;
uniform vec4 background;
uniform vec4 ambient;
uniform float ambientIntns;
uniform vec3 lightPosition;

mat3 rotMatrix, irotMatrix;

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
        
        float b01 = a22 * a11 - a12 * a21;
        float b11 = -a22 * a10 + a12 * a20;
        float b21 = a21 * a10 - a11 * a20;
        
        float det = a00 * b01 + a01 * b11 + a02 * b21;
        
        return mat3(b01, (-a22 * a01 + a02 * a21), (a12 * a01 - a02 * a11),
                  b11, (a22 * a00 - a02 * a20), (-a12 * a00 + a02 * a10),
                  b21, (-a21 * a00 + a01 * a20), (a11 * a00 - a01 * a10)) / det;
    }
#endregion

#region ////============= Util ==============
	
    float dot2( in vec2 v ) { return dot(v,v); }
	float dot2( in vec3 v ) { return dot(v,v); }
	float ndot( in vec2 a, in vec2 b ) { return a.x*b.x - a.y*b.y; }
	
	vec4 sampleTexture(int index, vec2 coord) {
		if(coord.x < 0. || coord.y < 0. || coord.x > 1. || coord.y > 1.) return vec4(0.);
		
		float i = float(index);
		
		float txIndex = floor(i / TEXTURE_S);
		float stcInd  = i - txIndex * TEXTURE_S;
		
		float row     = floor(stcInd / TEXTURE_N);
		float col     = stcInd - row * TEXTURE_N;
		
		vec2 tx = vec2(col, row) * TEXTURE_T;
		vec2 sm = tx + coord * TEXTURE_T;
		
			 if(txIndex == 0.) return texture2D(texture0, sm);
		else if(txIndex == 1.) return texture2D(texture1, sm);
		else if(txIndex == 2.) return texture2D(texture2, sm);
		else if(txIndex == 3.) return texture2D(texture3, sm);
		
		return texture2D(texture0, sm);
	}
#endregion

#region ////========== Primitives ===========
    
	float sdPlane( vec3 p, vec3 n, float h ) {
		return dot(p,n) + h;
	}
	
    float sdBox( vec3 p, vec3 b ) {
        vec3 q = abs(p) - b;
        return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
    }
    
    float sdBoxFrame( vec3 p, vec3 b, float e ) {
		p = abs(p)-b;
		vec3 q = abs(p+e)-e;
		return min(min(
			length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
			length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
			length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////
    
    float sdSphere(vec3 p, float radius) {
        return length(p) - radius;
    }
    
    float sdEllipsoid( vec3 p, vec3 r ) {
		float k0 = length(p/r);
		float k1 = length(p/(r*r));
		return k0*(k0-1.0)/k1;
	}
	
    float sdTorus( vec3 p, vec2 t ) {
		vec2 q = vec2(length(p.xz)-t.x,p.y);
		return length(q)-t.y;
	}
	
	// r is the sphere's radius, h is the plane's position
	float sdCutSphere( vec3 p, float r, float h ) {
		// sampling independent computations (only depend on shape)
		float w = sqrt(r*r-h*h);
		
		// sampling dependant computations
		vec2 q = vec2( length(p.xz), p.y );
		float s = max( (h-r)*q.x*q.x+w*w*(h+r-2.0*q.y), h*q.x-w*q.y );
		return (s<0.0) ? length(q)-r :
		     (q.x<w) ? h - q.y     :
		               length(q-vec2(w,h));
	}
	
	// r = sphere's radius
	// h = cutting's plane's position
	// t = thickness
	float sdCutHollowSphere( vec3 p, float r, float h, float t ) {
		// sampling independent computations (only depend on shape)
		float w = sqrt(r*r-h*h);
		
		// sampling dependant computations
		vec2 q = vec2( length(p.xz), p.y );
		return ((h*q.x<w*q.y) ? length(q-vec2(w,h)) : 
		                      abs(length(q)-r) ) - t;
	}

    float sdCappedTorus( vec3 p, float an, float ra, float rb) {
    	vec2 sc = vec2(sin(an),cos(an));
    	
		p.x = abs(p.x);
		float k = (sc.y*p.x>sc.x*p.y) ? dot(p.xy,sc) : length(p.xy);
		return sqrt( dot(p,p) + ra*ra - 2.0*ra*k ) - rb;
	}
	
    //////////////////////////////////////////////////////////////////////////////////////////////
    
	float sdCylinder( vec3 p, vec3 c ) {
		return length(p.xz-c.xy)-c.z;
	}
	
	float sdCappedCylinder( vec3 p, float h, float r ) {
		vec2 d = abs(vec2(length(p.xz),p.y)) - vec2(r,h);
		return min(max(d.x,d.y),0.0) + length(max(d,0.0));
	}
	
	float sdCapsule( vec3 p, vec3 a, vec3 b, float r ) {
		vec3 pa = p - a, ba = b - a;
		float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
		return length( pa - ba*h ) - r;
	}
	
	float sdCone( vec3 p, float an, float h ) {
		vec2 c = vec2(sin(an),cos(an));
		// c is the sin/cos of the angle, h is height
		// Alternatively pass q instead of (c,h),
		// which is the point at the base in 2D
		vec2 q = h*vec2(c.x/c.y,-1.0);
		
		vec2 w = vec2( length(p.xz), p.y );
		vec2 a = w - q*clamp( dot(w,q)/dot(q,q), 0.0, 1.0 );
		vec2 b = w - q*vec2( clamp( w.x/q.x, 0.0, 1.0 ), 1.0 );
		float k = sign( q.y );
		float d = min(dot( a, a ),dot(b, b));
		float s = max( k*(w.x*q.y-w.y*q.x),k*(w.y-q.y)  );
		return sqrt(d)*sign(s);
	}
	
	float sdCappedCone( vec3 p, float h, float r1, float r2 ) {
		vec2 q = vec2( length(p.xz), p.y );
		vec2 k1 = vec2(r2,h);
		vec2 k2 = vec2(r2-r1,2.0*h);
		vec2 ca = vec2(q.x-min(q.x,(q.y<0.0)?r1:r2), abs(q.y)-h);
		vec2 cb = q - k1 + k2*clamp( dot(k1-q,k2)/dot2(k2), 0.0, 1.0 );
		float s = (cb.x<0.0 && ca.y<0.0) ? -1.0 : 1.0;
		return s*sqrt( min(dot2(ca),dot2(cb)) );
	}
	
	float sdRoundCone( vec3 p, float h, float r1, float r2 ) {
		// sampling independent computations (only depend on shape)
		float b = (r1-r2)/h;
		float a = sqrt(1.0-b*b);
		
		// sampling dependant computations
		vec2 q = vec2( length(p.xz), p.y );
		float k = dot(q,vec2(-b,a));
		if( k<0.0 ) return length(q) - r1;
		if( k>a*h ) return length(q-vec2(0.0,h)) - r2;
		return dot(q, vec2(a,b) ) - r1;
	}

	float sdSolidAngle( vec3 p, float an, float ra ) {
		vec2 c = vec2(sin(an),cos(an));
		vec2 q = vec2( length(p.xz), p.y );
		float l = length(q) - ra;
		float m = length(q - c*clamp(dot(q,c),0.0,ra) );
		return max(l,m*sign(c.y*q.x-c.x*q.y));
	}
	
    //////////////////////////////////////////////////////////////////////////////////////////////
    
    float sdOctahedron( vec3 p, float s ) {
		p = abs(p);
		float m = p.x+p.y+p.z-s;
		vec3 q;
		   if( 3.0*p.x < m ) q = p.xyz;
		else if( 3.0*p.y < m ) q = p.yzx;
		else if( 3.0*p.z < m ) q = p.zxy;
		else return m*0.57735027;
		
		float k = clamp(0.5*(q.z-q.y+s),0.0,s); 
		return length(vec3(q.x,q.y-s+k,q.z-k)); 
	}
	
	float sdPyramid( vec3 p, float h ) {
		float m2 = h*h + 0.25;
		
		p.xz = abs(p.xz);
		p.xz = (p.z>p.x) ? p.zx : p.xz;
		p.xz -= 0.5;
		
		vec3 q = vec3( p.z, h*p.y - 0.5*p.x, h*p.x + 0.5*p.y);
		
		float s = max(-q.x,0.0);
		float t = clamp( (q.y-0.5*p.z)/(m2+0.25), 0.0, 1.0 );
		
		float a = m2*(q.x+s)*(q.x+s) + q.y*q.y;
		float b = m2*(q.x+0.5*t)*(q.x+0.5*t) + (q.y-m2*t)*(q.y-m2*t);
		
		float d2 = min(q.y,-q.x*m2-q.y*0.5) > 0.0 ? 0.0 : min(a,b);
		
		return sqrt( (d2+q.z*q.z)/m2 ) * sign(max(q.z,-p.y));
	}
	
#endregion

#region ////============ Modify =============
	
	vec4 opElongate( in vec3 p, in vec3 h ) {
	    vec3 q = abs(p)-h;
	    return vec4( max(q,0.0), min(max(q.x,max(q.y,q.z)),0.0) );
	}
	
	vec3 wave(vec3 p) {
	    p.x += sin(p.y * waveAmp.y + waveShift.x * PI * 2.) * waveInt.x + 
	    	   sin(p.z * waveAmp.z + waveShift.x * PI * 2.) * waveInt.x;
	    p.y += sin(p.x * waveAmp.x + waveShift.y * PI * 2.) * waveInt.y + 
	    	   sin(p.z * waveAmp.z + waveShift.y * PI * 2.) * waveInt.y;
	    p.z += sin(p.y * waveAmp.y + waveShift.z * PI * 2.) * waveInt.z + 
	    	   sin(p.x * waveAmp.x + waveShift.z * PI * 2.) * waveInt.z;
		return p;
	}
	
	vec3 twist(vec3 p) {
	    
	    float c = cos(twistAmount * p[twistAxis]);
	    float s = sin(twistAmount * p[twistAxis]);
	    mat2  m = mat2(c, -s, s, c);
	    
	    if(twistAxis == 0) {
	    	vec2 q = m * p.yz;
	    	return vec3(p.x, q);
	    	
	    } else if(twistAxis == 1) {
	    	vec2 q = m * p.xz;
	    	return vec3(q.x, p.y, q.y);
	    	
	    } else if(twistAxis == 2) {
	    	vec2 q = m * p.xy;
	    	return vec3(q, p.z);
	    	
	    } 
	    
	    return p;
	}
	
#endregion

#region ////=========== View Mod ============
	
	float round(float v) { return fract(v) >= 0.5? ceil(v) : floor(v); }
	vec3  round(vec3  v) { return vec3(round(v.x), round(v.y), round(v.z)); }
	
	vec3 tilePosition(vec3 p) {
		if(tileAmount == vec3(0.)) 
			return p - tileSize * round(p / tileSize);
		 return p - tileSize * clamp(round(p / tileSize), -tileAmount, tileAmount);
	}
	
#endregion

////========= Ray Marching ==========

float sceneSDF(vec3 p) { 
    float d;
    
    p  = irotMatrix * p;
    p /= objectScale;
    p -= position;
    
    p = wave(p);
    
    if(tileSize != vec3(0.))
    	p = tilePosition(p);
    
    p = twist(p);
    
    vec4 el = vec4(0.);
    
    if(elongate != vec3(0.)) {
	    el = opElongate(p, elongate);
	    p  = el.xyz;
    }
    
         if(shape == 100) d = sdPlane(p, vec3(0., -1., 0.), 0.);
    else if(shape == 101) d = sdBox(p, size / 2.);
    else if(shape == 102) d = sdBoxFrame(p, size / 2., thickness);
    
    else if(shape == 200) d = sdSphere(p, radius);
    else if(shape == 201) d = sdEllipsoid(p, size / 2.);
    else if(shape == 202) d = sdCutSphere(p, radius, crop);
    else if(shape == 203) d = sdCutHollowSphere(p, radius, crop, thickness);
    else if(shape == 204) d = sdTorus(p, vec2(radius, thickness));
    else if(shape == 205) d = sdCappedTorus(p, angle, radius, thickness);
    
    else if(shape == 300) d = sdCappedCylinder(p, height, radius);
    else if(shape == 301) d = sdCapsule(p, vec3(-height, 0., 0.), vec3(height, 0., 0.), radius);
    else if(shape == 302) d = sdCone(p, angle, height);
    else if(shape == 303) d = sdCappedCone(p, height, radRange.x, radRange.y);
    else if(shape == 304) d = sdRoundCone(p, height, radRange.x, radRange.y);
    else if(shape == 305) d = sdSolidAngle(p, angle, radius);
    
    else if(shape == 400) d = sdOctahedron(p, sizeUni);
    else if(shape == 401) d = sdPyramid(p, sizeUni);
    
    if(elongate != vec3(0.)) {
    	d += el.w;
    }
    
    d -= rounded;
    d *= objectScale;
    
    return d;
}

vec3 normal(vec3 p) {
    return normalize(vec3(
        sceneSDF(vec3(p.x + EPSILON, p.y, p.z)) - sceneSDF(vec3(p.x - EPSILON, p.y, p.z)),
        sceneSDF(vec3(p.x, p.y + EPSILON, p.z)) - sceneSDF(vec3(p.x, p.y - EPSILON, p.z)),
        sceneSDF(vec3(p.x, p.y, p.z + EPSILON)) - sceneSDF(vec3(p.x, p.y, p.z - EPSILON))
    ));
}

float march(vec3 camera, vec3 direction) {
    float depth = viewRange.x;
    
    for (int i = 0; i < MAX_MARCHING_STEPS; i++) {
        float dist = sceneSDF(camera + depth * direction);
        if (dist < EPSILON) 
			return depth;
        
        depth += dist;
        if (depth >= viewRange.y)
            return viewRange.y;
    }
    
    return viewRange.y;
}

void main() {
	gl_FragColor = drawBg == 1? background : vec4(0.);
	
	mat3 rx = rotateX(rotation.x);
    mat3 ry = rotateY(rotation.y);
    mat3 rz = rotateZ(rotation.z);
    rotMatrix  = rx * ry * rz;
    irotMatrix = inverse(rotMatrix);
    
	vec3 eye, dir;
	
	if(ortho == 1) {
		dir = vec3(0., 0., 1.);
		eye = vec3((v_vTexcoord - .5) * 2. * orthoScale, viewRange.x);
		
	} else {
	    float z = 1. / tan(radians(fov) / 2.);
	    dir = normalize(vec3((v_vTexcoord - .5) * 2., -z));
	    eye = vec3(0., 0., 5.);
	}
	
    float dist = march(eye, dir);
    vec3  coll = eye + dir * dist;
    vec3 wcoll = irotMatrix * coll;
    
    if(dist > viewRange.y - EPSILON) // Not hitting anything.
        return;
    
    vec3 c = ambient.rgb;
    
    ///////////////////////////////////////////////////////////
    float distNorm = (dist - viewRange.x) / (viewRange.y - viewRange.x);
    distNorm = 1. - distNorm;
    distNorm = smoothstep(.0, .3, distNorm);
    c = mix(background.rgb, c, mix(1., distNorm, depthInt));
    
    vec3 norm  = normal(coll);
    vec3 light = normalize(lightPosition);
    float lamo = dot(norm, light) + ambientIntns;
    
    c = mix(background.rgb, c, lamo);
    // c *= lamo;
    
    gl_FragColor = vec4(c, 1.);
}