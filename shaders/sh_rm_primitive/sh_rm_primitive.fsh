//Inigo Quilez 
//Oh where would I be without you.

#define MAX_SHAPES 16
#define MAX_OP     32

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

uniform int   operations[MAX_OP];
uniform int   opLength;

///////////////////////////////////////////////////////////////////

uniform int   shapeAmount;

uniform int   shape[MAX_SHAPES]                                   ;
uniform vec3  size[MAX_SHAPES]                                    ;
uniform float radius[MAX_SHAPES]                                  ;
uniform float thickness[MAX_SHAPES]                               ;
uniform float crop[MAX_SHAPES]                                    ;
uniform float angle[MAX_SHAPES]                                   ;
uniform float height[MAX_SHAPES]                                  ;
uniform vec2  radRange[MAX_SHAPES]                                ;
uniform float sizeUni[MAX_SHAPES]                                 ;
uniform vec3  elongate[MAX_SHAPES]                                ;
uniform float rounded[MAX_SHAPES]                                 ;
uniform vec4  corner[MAX_SHAPES]                                  ;
uniform vec2  size2D[MAX_SHAPES]                                  ;
uniform int   sides[MAX_SHAPES]                                   ;

uniform vec3  waveAmp[MAX_SHAPES]                                 ;
uniform vec3  waveInt[MAX_SHAPES]                                 ;
uniform vec3  waveShift[MAX_SHAPES]                               ;

uniform int   twistAxis[MAX_SHAPES]                               ;
uniform float twistAmount[MAX_SHAPES]                             ;

uniform vec3  position[MAX_SHAPES]                                ;
uniform vec3  rotation[MAX_SHAPES]                                ;
uniform float objectScale[MAX_SHAPES]                             ;

uniform vec3  tileSize[MAX_SHAPES]                                ;
uniform vec3  tileAmount[MAX_SHAPES]                              ;

uniform vec4  diffuseColor[MAX_SHAPES]                            ;
uniform float reflective[MAX_SHAPES]                              ;

uniform int   volumetric[MAX_SHAPES]                              ;
uniform float volumeDensity[MAX_SHAPES]                           ;

uniform int   useTexture[MAX_SHAPES]                              ;
uniform float textureScale[MAX_SHAPES]                            ;
uniform float triplanar[MAX_SHAPES]                               ;

///////////////////////////////////////////////////////////////////

uniform int   ortho;
uniform float fov;
uniform float orthoScale;
uniform vec2  viewRange;
uniform float depthInt;

uniform int   drawBg;
uniform vec4  background;
uniform float ambientIntns;
uniform vec3  lightPosition;

uniform int   useEnv;

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
	
	vec2 equirectangularUv(vec3 dir) {
		vec3 n = normalize(dir);
		return vec2((atan(n.x, n.z) / (PI * 2.)) + 0.5, 1. - acos(n.y) / PI);
	}
	
#endregion

#region ////======== 2D Primitives ==========
	
	float sdRoundedBox( in vec2 p, in vec2 b, in vec4 r ) {
	    r.xy = (p.x > 0.0)? r.xy : r.zw;
	    r.x  = (p.y > 0.0)? r.x  : r.y;
	    vec2 q = abs(p) - b + r.x;
	    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r.x;
	}
	
	float sdRegularPolygon(in vec2 p, in float r, in int n ) {
	    // these 4 lines can be precomputed for a given shape
	    float an = 3.141593 / float(n);
	    vec2  acs = vec2(cos(an), sin(an));
	
	    // reduce to first sector
	    float bn = mod(atan(p.x, p.y), 2.0 * an) - an;
	    p = length(p) * vec2(cos(bn), abs(sin(bn)));
	
	    // line sdf
	    p -= r * acs;
	    p.y += clamp( -p.y, 0.0, r * acs.y);
	    return length(p) * sign(p.x);
	}
		
#endregion

#region ////======== 3D Primitives ==========
    
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
	    vec3 q = abs(p) - h;
	    return vec4( max(q, 0.0),  min(max(q.x, max(q.y, q.z)), 0.0) );
	}
	
	float opExtrusion( in vec3 p, in float h, in float df2d ) {
	    vec2 w = vec2( df2d, abs(p.z) - h );
	    return min(max(w.x, w.y), 0.0) + length(max(w, 0.0));
	}

	vec3 wave(int index, vec3 p) {
	    p.x += sin(p.y * waveAmp[index].y + waveShift[index].x * PI * 2.) * waveInt[index].x + 
	    	   sin(p.z * waveAmp[index].z + waveShift[index].x * PI * 2.) * waveInt[index].x;
	    p.y += sin(p.x * waveAmp[index].x + waveShift[index].y * PI * 2.) * waveInt[index].y + 
	    	   sin(p.z * waveAmp[index].z + waveShift[index].y * PI * 2.) * waveInt[index].y;
	    p.z += sin(p.y * waveAmp[index].y + waveShift[index].z * PI * 2.) * waveInt[index].z + 
	    	   sin(p.x * waveAmp[index].x + waveShift[index].z * PI * 2.) * waveInt[index].z;
		return p;
	}
	
	vec3 twist(int index, vec3 p) {
	    
	    float c = cos(twistAmount[index] * p[twistAxis[index]]);
	    float s = sin(twistAmount[index] * p[twistAxis[index]]);
	    mat2  m = mat2(c, -s, s, c);
	    
	    if(twistAxis[index] == 0) {
	    	vec2 q = m * p.yz;
	    	return vec3(p.x, q);
	    	
	    } else if(twistAxis[index] == 1) {
	    	vec2 q = m * p.xz;
	    	return vec3(q.x, p.y, q.y);
	    	
	    } else if(twistAxis[index] == 2) {
	    	vec2 q = m * p.xy;
	    	return vec3(q, p.z);
	    	
	    } 
	    
	    return p;
	}
	
	float opSmoothUnion( float d1, float d2, float k ) {
	    float h = clamp( 0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0 );
	    return mix( d2, d1, h ) - k * h * (1.0 - h);
	}
	
	float opSmoothSubtraction( float d1, float d2, float k ) {
	    float h = clamp( 0.5 - 0.5 * (d2 + d1) / k, 0.0, 1.0 );
	    return mix( d2, -d1, h ) + k * h * (1.0 - h);
	}
	
	float opSmoothIntersection( float d1, float d2, float k ) {
	    float h = clamp( 0.5 - 0.5 * (d2 - d1) / k, 0.0, 1.0 );
	    return mix( d2, d1, h ) + k * h * (1.0 - h);
	}

#endregion

#region ////=========== View Mod ============
	
	float round(float v) { return fract(v) >= 0.5? ceil(v) : floor(v); }
	vec3  round(vec3  v) { return vec3(round(v.x), round(v.y), round(v.z)); }
	
	vec3 tilePosition(int index, vec3 p) {
		if(tileAmount[index] == vec3(0.)) 
			return p - tileSize[index] * round(p / tileSize[index]);
		 return p - tileSize[index] * clamp(round(p / tileSize[index]), -tileAmount[index], tileAmount[index]);
	}
	
#endregion

#region ////=========== Texturing ============
	
	vec4 boxmap( in int textureIndex, in vec3 p, in vec3 n, in float k ) {
	    // project+fetch
	    vec4 x = sampleTexture( textureIndex, fract(p.yz) );
	    vec4 y = sampleTexture( textureIndex, fract(p.zx) );
	    vec4 z = sampleTexture( textureIndex, fract(p.xy) );
	    
	    // blend weights
	    vec3 w = pow( abs(n), vec3(k) );
	    // blend and return
	    return (x * w.x + y * w.y + z * w.z) / (w.x + w.y + w.z);
	}

#endregion

////========= Ray Marching ==========

float sceneSDF(int index, vec3 p) { 
    float d;
    
    mat3 rx = rotateX(rotation[index].x);
    mat3 ry = rotateY(rotation[index].y);
    mat3 rz = rotateZ(rotation[index].z);
    rotMatrix  = rx * ry * rz;
    irotMatrix = inverse(rotMatrix);
    
    p /= objectScale[index];
	p -= position[index];
    p =  irotMatrix * p;
	
    p = wave(index, p);
    
    if(tileSize[index] != vec3(0.))
    	p = tilePosition(index, p);
    
    p = twist(index, p);
    
    vec4 el = vec4(0.);
    
    if(elongate[index] != vec3(0.)) {
	    el = opElongate(p, elongate[index]);
	    p  = el.xyz;
    }
    
    int shp = shape[index];
    
         if(shp == 100) d = sdPlane(           p, vec3(0., -1., 0.), 0.);
    else if(shp == 101) d = sdBox(             p, size[index] / 2.);
    else if(shp == 102) d = sdBoxFrame(        p, size[index] / 2., thickness[index]);
    else if(shp == 103) d = opExtrusion(       p, thickness[index], sdRoundedBox(p.xy, size2D[index], corner[index]));
    
    else if(shp == 200) d = sdSphere(          p, radius[index]);
    else if(shp == 201) d = sdEllipsoid(       p, size[index] / 2.);
    else if(shp == 202) d = sdCutSphere(       p, radius[index], crop[index]);
    else if(shp == 203) d = sdCutHollowSphere( p, radius[index], crop[index], thickness[index]);
    else if(shp == 204) d = sdTorus(           p, vec2(radius[index], thickness[index]));
    else if(shp == 205) d = sdCappedTorus(     p, angle[index], radius[index], thickness[index]);
    
    else if(shp == 300) d = sdCappedCylinder(  p, height[index], radius[index]);
    else if(shp == 301) d = sdCapsule(         p, vec3(-height[index], 0., 0.), vec3(height[index], 0., 0.), radius[index]);
    else if(shp == 302) d = sdCone(            p, angle[index], height[index]);
    else if(shp == 303) d = sdCappedCone(      p, height[index], radRange[index].x, radRange[index].y);
    else if(shp == 304) d = sdRoundCone(       p, height[index], radRange[index].x, radRange[index].y);
    else if(shp == 305) d = sdSolidAngle(      p, angle[index], radius[index]);
    else if(shp == 306) d = opExtrusion(       p, thickness[index], sdRegularPolygon(p.xy, 0.5, sides[index]));
    
    else if(shp == 400) d = sdOctahedron(      p, sizeUni[index]);
    else if(shp == 401) d = sdPyramid(         p, sizeUni[index]);
    
    if(elongate[index] != vec3(0.)) {
    	d += el.w;
    }
    
    d -= rounded[index];
    d *= objectScale[index];
    
    return d;
}

vec3 normal(int index, vec3 p) {
    return normalize(vec3(
        sceneSDF(index, vec3(p.x + EPSILON, p.y, p.z)) - sceneSDF(index, vec3(p.x - EPSILON, p.y, p.z)),
        sceneSDF(index, vec3(p.x, p.y + EPSILON, p.z)) - sceneSDF(index, vec3(p.x, p.y - EPSILON, p.z)),
        sceneSDF(index, vec3(p.x, p.y, p.z + EPSILON)) - sceneSDF(index, vec3(p.x, p.y, p.z - EPSILON))
    ));
}

float march(int index, vec3 camera, vec3 direction) {
	float depth = viewRange.x;
    
    for (int i = 0; i < MAX_MARCHING_STEPS; i++) {
        float dist = sceneSDF(index, camera + depth * direction);
        if (dist < EPSILON) 
			return depth;
        
        depth += dist;
        if (depth >= viewRange.y)
            return viewRange.y;
    }
	 
  return viewRange.y;  
}

float marchDensity(int index, vec3 camera, vec3 direction) {
	float st   = 1. / float(MAX_MARCHING_STEPS);
	float dens = 0.;
	float stp  = volumeDensity[index] == 0. ? 0. : pow(2., 10. * volumeDensity[index] * 0.5 - 10.);
	   
    for (int i = 0; i <= MAX_MARCHING_STEPS; i++) {
        float depth = mix(viewRange.x, viewRange.y, float(i) * st);
        vec3  pos   = camera + depth * direction;
        float hit   = sceneSDF(index, pos);
        float inst  = (pos.y + objectScale[index]) / (objectScale[index] * 2.);
              inst  = inst <= 0.? 0. : pow(2., 10. * inst - 10.) * 10.;
        
        if (hit <= 0.) dens += stp;
    }
    
    return dens;
}

vec4 scene(int index, out float depth, out vec3 coll, out vec3 norm) {
	depth = 0.;
	
    float dz  = 1. / tan(radians(fov) / 2.);
    vec3  dir = normalize(vec3((v_vTexcoord - .5) * 2., -dz));
    vec3  eye = vec3(0., 0., 5.);
	
	if(volumetric[index] == 1) {
		float _dens = clamp(marchDensity(index, eye, dir), 0., 1.);
		return diffuseColor[index] * _dens;
	}
	
    depth = march(index, eye, dir);
    coll  = eye + dir * depth;
    norm  = normal(index, coll);
    
    if(depth > viewRange.y - EPSILON) // Not hitting anything.
        return vec4(0.);
    
    vec3 c = useTexture[index] == 1? 
    	boxmap(int(TEXTURE_S) + index, irotMatrix * coll * textureScale[index], irotMatrix * norm, triplanar[index]).rgb * diffuseColor[index].rgb : 
    	diffuseColor[index].rgb;
    
    ///////////////////////////////////////////////////////////
    
    float distNorm = (depth - viewRange.x) / (viewRange.y - viewRange.x);
    distNorm = 1. - distNorm;
    distNorm = smoothstep(.0, .3, distNorm);
    c = mix(c * background.rgb, c, mix(1., distNorm, depthInt));
    
    ///////////////////////////////////////////////////////////
    
    if(useEnv == 1) {
    	vec3 ref  = reflect(dir, norm);
		vec4 refC = sampleTexture(0, equirectangularUv(ref));
		c = mix(c, c * refC.rgb, reflective[index]);
    }
	
    ///////////////////////////////////////////////////////////
    
    vec3 light = normalize(lightPosition);
    float lamo = min(1., max(0., dot(norm, light)) + ambientIntns);
    c = mix(c * background.rgb, c, lamo);
    
    return vec4(c, 1.);
}

vec4 blend(in vec4 bg, in vec4 fg) {
	float al = fg.a + bg.a * (1. - fg.a);
	if(al == 0.) return bg;
	
	vec4 res = ((fg * fg.a) + (bg * bg.a * (1. - fg.a))) / al;
	res.a = al;
	
	return res;
}

vec4 operate() {
	vec4  color[MAX_OP];
	vec3  colis[MAX_OP];
	vec3  norml[MAX_OP];
	float depth[MAX_OP];
	
	int top = 0;
	int opr = 0;
	
	float d1, d2, dm, rt;
	vec3  n1, n2, cl;
	vec4  c1, c2;
	float yy = viewRange.y - EPSILON;
	
	for(int i = 0; i < opLength; i++) {
		opr = operations[i];
		
		if(opr < 100) {
			color[top] = scene(opr, d1, cl, n1);
			depth[top] = d1;
			colis[top] = cl;
			norml[top] = n1;
			top++;
			
		} else {
			top--;
			c1 = color[top];
			d1 = depth[top];
			n1 = norml[top];
			
			top--;
			c2 = color[top];
			d2 = depth[top];
			n2 = norml[top];
			
			if(opr == 100) {
				if(d1 < d2) {
					color[top] = c1;
					depth[top] = d1;
					norml[top] = n1;
				} else {
					color[top] = c2;
					depth[top] = d2;
					norml[top] = n2;
				}
				top++;
			}
		}
	}
	
	return color[0];
}

void main() {
	
	vec4 bg = background;
	if(useEnv == 1) {
		float  edz  = 1. / tan(radians(fov * 2.) / 2.);
		vec3   edir = normalize(vec3((v_vTexcoord - .5) * 2., -edz));
		       //edir = normalize(irotMatrix * edir) / objectScale[index];
		
		vec2 envUV = equirectangularUv(edir);
		vec4 endC  = sampleTexture(0, envUV);
		bg = endC;
	}
	
	vec4  result = drawBg == 1? bg : vec4(0.);
	float d;
	vec3  c, n;
	
	if(operations[0] == -1)
		result = blend(result, scene(0, d, c, n));
	else
		result = blend(result, operate());
	
    //////////////////////////////////////////////////
    
    gl_FragColor = result;
}