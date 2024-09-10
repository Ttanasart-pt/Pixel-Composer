//Inigo Quilez 
//Oh where would I be without you.

#define MACOS 1

#ifdef MACOS
	#define MAX_SHAPES 16
	#define MAX_OP     32
#else
	#extension GL_OES_standard_derivatives : enable
	#define MAX_SHAPES 16
	#define MAX_OP     32
#endif

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

const float EPSILON = 1e-5;
const float PI = 3.14159265358979323846;

const float SUBTEXTURE_SIZE = 1024.;
const float TEXTURE_N  = 8192. / SUBTEXTURE_SIZE;
const float TEXTURE_S  = TEXTURE_N * TEXTURE_N;
const float TEXTURE_T  = SUBTEXTURE_SIZE / 8192.;
const float TEXTURE_TX = 1. / SUBTEXTURE_SIZE;

uniform sampler2D texture0;
uniform sampler2D texture1;
uniform sampler2D texture2;
uniform sampler2D texture3;

uniform int   MAX_MARCHING_STEPS;
uniform int   operations[MAX_OP];
uniform float opArgument[MAX_OP];
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

uniform int   tileActive[MAX_SHAPES]                              ;
uniform vec3  tileSize[MAX_SHAPES]                                ;
uniform vec3  tileAmount[MAX_SHAPES]                              ;
uniform vec3  tileShiftPos[MAX_SHAPES]                            ;
uniform vec3  tileShiftRot[MAX_SHAPES]                            ;
uniform float tileShiftSca[MAX_SHAPES]                            ;

uniform vec4  diffuseColor[MAX_SHAPES]                            ;
uniform float reflective[MAX_SHAPES]                              ;

uniform int   volumetric[MAX_SHAPES]                              ;
uniform float volumeDensity[MAX_SHAPES]                           ;

uniform int   useTexture[MAX_SHAPES]                              ;
uniform int   textureFilter[MAX_SHAPES]                           ;
uniform float textureScale[MAX_SHAPES]                            ;
uniform float triplanar[MAX_SHAPES]                               ;

///////////////////////////////////////////////////////////////////

uniform vec3  camRotation;
uniform float camScale;
uniform float camRatio;

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
uniform int   envFilter;
uniform int   drawGrid;
uniform float gridStep;
uniform float gridScale;
uniform float axisBlend;

float influences[MAX_SHAPES]; 

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
	
	float random  (in vec3 st) { return fract(sin(dot(st + vec3(1.0534, 0.453, 1.678), vec3(12.9898, 78.233, 63.1076))) * 43758.5453123); }
	
	float round(float v) { return fract(v) >= 0.5? ceil(v) : floor(v); }
	vec3  round(vec3  v) { return vec3(round(v.x), round(v.y), round(v.z)); }
	
    float dot2( in vec2 v ) { return dot(v,v); }
	float dot2( in vec3 v ) { return dot(v,v); }
	float ndot( in vec2 a, in vec2 b ) { return a.x*b.x - a.y*b.y; }
	
	vec4 sampleTexture(int textureIndex, vec2 coord, int interpolation) { 
		if(coord.x < 0. || coord.y < 0. || coord.x > 1. || coord.y > 1.) return vec4(0.);
		
		float i = float(textureIndex);
		
		float txIndex = floor(i / TEXTURE_S);
		float stcInd  = i - txIndex * TEXTURE_S;
		
		float row     = floor(stcInd / TEXTURE_N);
		float col     = stcInd - row * TEXTURE_N;
		
		vec2 cl = vec2(col, row);
		vec2 sm = (cl + coord) * TEXTURE_T;
		
		if(interpolation == 0) {
			     if(txIndex == 0.) return texture2D(texture0, sm);
			else if(txIndex == 1.) return texture2D(texture1, sm);
			else if(txIndex == 2.) return texture2D(texture2, sm);
			else				   return texture2D(texture3, sm);
			
			
		} else if(interpolation == 1) {
			vec2 fr  = fract(coord * SUBTEXTURE_SIZE); 
			vec2 sm1 = (cl + clamp(coord + vec2(TEXTURE_TX,         0.), 0., 1.)) * TEXTURE_T;
			vec2 sm2 = (cl + clamp(coord + vec2(        0., TEXTURE_TX), 0., 1.)) * TEXTURE_T;
			vec2 sm3 = (cl + clamp(coord + vec2(TEXTURE_TX, TEXTURE_TX), 0., 1.)) * TEXTURE_T;
			
				 if(txIndex == 0.) return mix(mix(texture2D(texture0, sm ), texture2D(texture0, sm1), fr.x), 
                                              mix(texture2D(texture0, sm2), texture2D(texture0, sm3), fr.x), fr.y);
			else if(txIndex == 1.) return mix(mix(texture2D(texture1, sm ), texture2D(texture1, sm1), fr.x), 
                                              mix(texture2D(texture1, sm2), texture2D(texture1, sm3), fr.x), fr.y);
			else if(txIndex == 2.) return mix(mix(texture2D(texture2, sm ), texture2D(texture2, sm1), fr.x), 
                                              mix(texture2D(texture2, sm2), texture2D(texture2, sm3), fr.x), fr.y);
			else				   return mix(mix(texture2D(texture3, sm ), texture2D(texture3, sm1), fr.x), 
                                              mix(texture2D(texture3, sm2), texture2D(texture3, sm3), fr.x), fr.y);
			
		}
		
		return vec4(0.);
	}
	
	vec2 equirectangularUv(vec3 dir) {
		vec3 n = normalize(dir);
		return vec2((atan(n.x, n.z) / (PI * 2.)) + 0.5, 1. - acos(n.y) / PI);
	}
	
	vec4 blend(in vec4 bg, in vec4 fg) {
		float al = fg.a + bg.a * (1. - fg.a);
		if(al == 0.) return bg;
		
		vec4 res = ((fg * fg.a) + (bg * bg.a * (1. - fg.a))) / al;
		res.a = al;
		
		return res;
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
	
	float sdPie( in vec2 p, in float angle, in float r ) {
		vec2 c = vec2(sin(angle), cos(angle));
		
	    p.x = abs(p.x);
	    float l = length(p) - r;
	    float m = length(p - c * clamp(dot(p, c), 0.0, r)); // c=sin/cos of aperture
	    return max(l, m * sign(c.y * p.x - c.x * p.y));
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

	vec3 wave(vec3 amp, vec3 shift, vec3 inten, vec3 p) {
	    p.x += sin(p.y * amp.y + shift.x * PI * 2.) * inten.x + 
	    	   sin(p.z * amp.z + shift.x * PI * 2.) * inten.x;
	    p.y += sin(p.x * amp.x + shift.y * PI * 2.) * inten.y + 
	    	   sin(p.z * amp.z + shift.y * PI * 2.) * inten.y;
	    p.z += sin(p.y * amp.y + shift.z * PI * 2.) * inten.z + 
	    	   sin(p.x * amp.x + shift.z * PI * 2.) * inten.z;
		return p;
	}
	
	vec3 twist(float amo, int axis, vec3 p) {
	    
	    float c = cos(amo * p[axis]);
	    float s = sin(amo * p[axis]);
	    mat2  m = mat2(c, -s, s, c);
	    
	    if(axis == 0) {
	    	vec2 q = m * p.yz;
	    	return vec3(p.x, q);
	    	
	    } else if(axis == 1) {
	    	vec2 q = m * p.xz;
	    	return vec3(q.x, p.y, q.y);
	    	
	    } else if(axis == 2) {
	    	vec2 q = m * p.xy;
	    	return vec3(q, p.z);
	    	
	    } 
	    
	    return p;
	}
	
#endregion

#region ////============ Combine =============

	vec2 smin( float a, float b, float k ) {
	    float h = 1.0 - min( abs(a - b) / (4.0 * k), 1.0 );
	    float w = h * h;
	    float m = w * 0.5;
	    float s = w * k;
	    return (a < b) ? vec2(a - s, m) : vec2(b - s, 1.0 - m);
	}
	
	float opSmoothSubtraction( float d1, float d2, float k ) {
	    float h = clamp( 0.5 - 0.5 * (d2 + d1) / k, 0.0, 1.0 );
	    return mix( d2, -d1, h ) + k * h * (1.0 - h);
	}

	float opSmoothIntersection( float d1, float d2, float k ) {
	    float h = clamp( 0.5 - 0.5*(d2-d1)/k, 0.0, 1.0 );
	    return mix( d2, d1, h ) + k*h*(1.0-h);
	}
	
#endregion
	
#region ////=========== View Mod ============
	
	vec3 tilePosition(vec3 amount, vec3 size, vec3 p) {
		if(amount == vec3(0.)) 
			return p - size * round(p / size);
		return p - size * clamp(round(p / size), -amount, amount);
	}
	
	vec3 tileIndex(vec3 amount, vec3 size, vec3 p) {
		if(amount == vec3(0.)) 
			return size * round(p / size);
		return size * clamp(round(p / size), -amount, amount);
	}

#endregion

#region ////=========== Texturing ============
	
	vec4 boxmap( in int textureIndex, in vec3 p, in vec3 n, in float k, int interpolation ) {
	    // project+fetch
	    vec4 x = sampleTexture( textureIndex, fract(p.yz), interpolation );
	    vec4 y = sampleTexture( textureIndex, fract(p.zx), interpolation );
	    vec4 z = sampleTexture( textureIndex, fract(p.xy), interpolation );
	    
	    // blend weights
	    vec3 w = pow( abs(n), vec3(k) );
	    // blend and return
	    return (x * w.x + y * w.y + z * w.z) / (w.x + w.y + w.z);
	}
	
	
	vec4 viewGrid(vec2 pos, float scale) {
	    vec2 coord      = pos * scale; // use the scale variable to set the distance between the lines
	    vec2 derivative = fwidth(coord);
	    vec2 grid       = abs(fract(coord - 0.5) - 0.5) / derivative;
	    float line      = min(grid.x, grid.y);
	    float minimumy  = min(derivative.y, 1.);
	    float minimumx  = min(derivative.x, 1.);
	    vec4 color = vec4(.3, .3, .3, 1. - min(line, 1.));
	    
	    // y axis
	    if(pos.x > -1. * minimumx / scale && pos.x < 1. * minimumx / scale)
	        color.y = 0.3 + axisBlend * 0.7;
	    // x axis
	    
	    if(pos.y > -1. * minimumy / scale && pos.y < 1. * minimumy / scale)
	        color.x = 0.3 + axisBlend * 0.7;
	    return color;
	}
	
#endregion

////========= Ray Marching ==========

float sceneSDF(int index, vec3 p) { 
    float d;
    
    mat3 rx = rotateX(rotation[index].x);
    mat3 ry = rotateY(rotation[index].y);
    mat3 rz = rotateZ(rotation[index].z);
    mat3 rotMatrix  = rx * ry * rz;
    mat3 irotMatrix = inverse(rotMatrix);
    
    float sca = objectScale[index];
	p -= position[index];
    p =  irotMatrix * p;
    p /= sca;
	
    p = wave(waveAmp[index], waveShift[index], waveInt[index], p);
    
    if(tileActive[index] == 1) {
    	vec3 tindex = tileIndex(tileAmount[index], tileSize[index], p);
    	
    	vec3  tpos   =      tileShiftPos[index] * (random(tindex + vec3(1., 0., 0.)) * 2. - 1.);
    	vec3  trot   =      tileShiftRot[index] * (random(tindex + vec3(0., 1., 0.)) * 2. - 1.);
    	float tsca   = 1. + tileShiftSca[index] * (random(tindex + vec3(0., 0., 1.)) * 2. - 1.);
    	
    	tindex += tpos;
    	p = p - tindex;
    	
	    mat3 trx = rotateX(trot.x);
	    mat3 try = rotateY(trot.y);
	    mat3 trz = rotateZ(trot.z);
	    mat3 trotMatrix  = rx * ry * rz;
	    mat3 tirotMatrix = inverse(trotMatrix);
	    
    	sca *= tsca;
    	p /= tsca;
	    p =  tirotMatrix * p;
    }
    
    p = twist(twistAmount[index], twistAxis[index], p);
    
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
    else if(shp == 307) d = opExtrusion(       p, thickness[index], sdPie(p.xy, angle[index], radius[index]));
    
    else if(shp == 400) d = sdOctahedron(      p, sizeUni[index]);
    else if(shp == 401) d = sdPyramid(         p, sizeUni[index]);
    
    if(elongate[index] != vec3(0.)) {
    	d += el.w;
    }
    
    d -= rounded[index];
    d *= sca;
    
    return d;
}

float operateSceneSDF(vec3 p, out vec3 blendIndx) {
	blendIndx = vec3(0., 0., 1.);
	
	if(operations[0] == -1) {
		influences[0] = 1.;
		return sceneSDF(0, p);
	}
	
	float depth[MAX_OP];
	int   index[MAX_OP];
	
	float d1, d2, mrg;
	int   o1, o2;
	int   top = 0;
	int   opr = 0;
	
	for(int i = 0; i < opLength; i++) {
		opr = operations[i];
		mrg = opArgument[i];
		
		if(opr < 100) {
			depth[top] = sceneSDF(opr, p);
			index[top] = opr;
			top++;
			
		} else if(top >= 2) {
			top--;
			d1 = depth[top];
			o1 = index[top];
			
			top--;
			d2 = depth[top];
			o2 = index[top];
			
			if(opr == 100) {
				if(d1 < d2) {
					depth[top] = d1;
					index[top] = o1;
					blendIndx.x = float(o1);
					
					influences[o1] = 1.;
					influences[o2] = 0.;
					
				} else {
					depth[top] = d2;
					index[top] = o2;
					blendIndx.x = float(o2);
					
					influences[o1] = 0.;
					influences[o2] = 1.;
						
				}
				
			} else if(opr == 101) {
				vec2 m = smin(d1, d2, mrg);
				blendIndx.x = float(o1);
				blendIndx.y = float(o2);
				blendIndx.z = m.y;
				
				influences[o1] = 1. - m.y;
				influences[o2] = m.y;
				
				depth[top]  = m.x;
				index[top]  = d1 < d2? o1 : o2;
				
			} else if(opr == 102) {
				float m = opSmoothSubtraction(d1, d2, mrg);
				blendIndx.x = float(o2);
				
				influences[o1] = 0.;
				influences[o2] = 1.;
				
				depth[top]  = m;
				index[top]  = o2;
				
			} else if(opr == 103) {
				float m = opSmoothIntersection(d1, d2, mrg);
				blendIndx.x = float(o1);
				
				influences[o1] = 1.;
				influences[o2] = 0.;
				
				depth[top]  = m;
				index[top]  = o1;
				
			}
			
			top++;
			
		} else  //error, not enough values
			break;
	}
	
	return depth[0];
}

vec3 normal(vec3 p) {
	vec3 b;
	
	vec2 e = vec2(1.0, -1.0) * 0.0001;
	return normalize( e.xyy * operateSceneSDF( p + e.xyy, b ) + 
					  e.yyx * operateSceneSDF( p + e.yyx, b ) + 
					  e.yxy * operateSceneSDF( p + e.yxy, b ) + 
					  e.xxx * operateSceneSDF( p + e.xxx, b ) );
    
}

float march(vec3 camera, vec3 direction, out vec3 blendIndx) {
    if(shapeAmount == 0) return viewRange.y;
	float depth = viewRange.x;
    
    for (int i = 0; i < MAX_MARCHING_STEPS; i++) {
        float dist = operateSceneSDF(camera + depth * direction, blendIndx);
        if (dist < EPSILON) 
			return depth;
        
        depth += dist;
        if (depth >= viewRange.y)
            return viewRange.y;
    }
	 
	return viewRange.y;  
}

float marchLinear(vec3 camera, vec3 direction, out vec3 blendIndx) {
	float st   = 1. / float(MAX_MARCHING_STEPS);
	
    for (int i = 0; i <= MAX_MARCHING_STEPS; i++) {
        float depth = mix(viewRange.x, viewRange.y, float(i) * st);
        vec3  pos   = camera + depth * direction;
        float hit   = operateSceneSDF(pos, blendIndx);
        
        if (hit <= 0.)
        	return depth;
    }
    
    return viewRange.y;
}

float marchDensity(vec3 camera, vec3 direction) {
	float maxx    = float(MAX_MARCHING_STEPS);
	float st      = 1. / maxx;
	float density = 0.;
	float dens, stp;
	vec3  blendIndx;
	 
    for (float i = 0.; i <= maxx; i++) {
        float depth = mix(viewRange.x, viewRange.y, i * st);
        vec3  pos   = camera + depth * direction;
        float hit   = operateSceneSDF(pos, blendIndx);
        
        if (hit <= 0.) {
        	dens = volumeDensity[int(floor(blendIndx.x))];
        	stp  = dens == 0. ? 0. : pow(2., 10. * dens - 10.);
        	
        	density += stp;
        }
    }
    
    return density;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

vec4 scene() {
    mat3 rx = rotateX(camRotation.x);
    mat3 ry = rotateY(camRotation.y);
    mat3 rz = rotateZ(camRotation.z);
    mat3 camRotMatrix  = rx * ry * rz;
    mat3 camIrotMatrix = inverse(camRotMatrix);
    
    vec3 dir, eye;
    
    vec2  cps = (v_vTexcoord - .5) * 2.;
		  cps.x *= camRatio;
    		  
    if(ortho == 0) {
	    float dz  = 1. / tan(radians(fov) / 2.);
	    	  
	    dir = vec3(cps, -dz);
	    eye = vec3(0., 0., 5.);
	    
    } else if(ortho == 1) {
    		  
    	dir = vec3(0., 0., -1.);
	    eye = vec3(cps * orthoScale, 5.);
    }
    
    dir  = normalize(camIrotMatrix * dir);
	eye  = camIrotMatrix * eye;
    eye /= camScale;
	
	if(volumetric[0] == 1) { 
		float _dens = clamp(marchDensity(eye, dir), 0., 1.);
		return diffuseColor[0] * _dens;
	}
	
	vec3  blendIndx;
    float depth = march(eye, dir, blendIndx);
    
    int   idx0  = int(floor(blendIndx.x));
    int   idx1  = int(floor(blendIndx.y));
    float rat   = blendIndx.z;
    
    vec3 coll  = eye + dir * depth;
    vec3 norm  = normal(coll);
    vec4 grid  = vec4(0.);
    
    if(drawGrid == 1 && (shapeAmount == 0 || sign(eye.y) != sign(coll.y))) {
		vec3  gp = eye + dir * depth * (abs(eye.y) / (abs(coll.y) + abs(eye.y)));
		grid = viewGrid( gp.xz, gridStep );
		grid.a *= clamp(1. - length(gp.xz) * gridScale, 0., 1.) * 0.75;
    }
    
    if(shapeAmount == 0 || depth > viewRange.y - EPSILON) // Not hitting anything.
        return drawGrid == 1? grid : vec4(0.);
    
    ///////////////////////////////////////////////////////////
    
    float totalInfluences = 0.;
    for(int i = 0; i < shapeAmount; i++)
    	totalInfluences += influences[i];
    
    vec3  c    = vec3(0.);
    float refl = 0.;
    
    if(totalInfluences > 0.) {
	    for(int i = 0; i < shapeAmount; i++) {
	    	if(influences[i] == 0.) continue;
	    	
	    	rx = rotateX(rotation[i].x);
		    ry = rotateY(rotation[i].y);
		    rz = rotateZ(rotation[i].z);
		    mat3 rotMatrix  = rx * ry * rz;
		    mat3 irotMatrix = inverse(rotMatrix);
		    
		    vec3 _c = diffuseColor[i].rgb;
		    
		    if(useTexture[i] == 1) {
		    	int indx = int(TEXTURE_S) + i;
		    	vec3 pos = irotMatrix * (coll - position[i]) * textureScale[i];
		    	vec3 nor = irotMatrix * norm;
		    	
		    	_c  = boxmap(indx, pos, nor, triplanar[i], textureFilter[i]).rgb;
		    	_c *= diffuseColor[i].rgb;
		    }
		    
		    c    += _c * (influences[i] / totalInfluences);
		    refl += reflective[i] * (influences[i] / totalInfluences);
	    }
    }
    
    vec3 ref   = reflect(dir, norm);
    vec3 bgClr = background.rgb;
  //  if(useEnv == 1) {
  //  	vec4 refC = sampleTexture(0, equirectangularUv(norm), 0);
		// bgClr *= refC.rgb;
  //  }
    
    ///////////////////////////////////////////////////////////
    
    float distNorm = (depth - viewRange.x) / (viewRange.y - viewRange.x);
    distNorm = 1. - distNorm;
    distNorm = smoothstep(.0, .3, distNorm);
    c = mix(c * bgClr, c, mix(1., distNorm, depthInt));
    
    ///////////////////////////////////////////////////////////
    
    if(useEnv == 1) {
		vec4 refC = sampleTexture(0, equirectangularUv(ref), envFilter);
		c = mix(c, c * refC.rgb, refl);
    }
	
    ///////////////////////////////////////////////////////////
    
    vec3 light = normalize(lightPosition);
    float lamo = min(1., max(0., dot(norm, light)) + ambientIntns);
    c = mix(c * bgClr, c, lamo);
    
    ///////////////////////////////////////////////////////////
    
    vec4 res = vec4(c, 1.);
    
    if(drawGrid == 1 && sign(eye.y) != sign(coll.y))
		res = blend(res, grid);
    
    return res;
}

void main() {
	
	vec4 bg = background;
	if(useEnv == 1) {
		// float  edz  = 1. / tan(radians(fov * 2.) / 2.);
		// vec3   edir = normalize(vec3((v_vTexcoord - .5) * 2., -edz));
		
		mat3 rx = rotateX(camRotation.x);
	    mat3 ry = rotateY(camRotation.y);
	    mat3 rz = rotateZ(camRotation.z);
	    mat3 camRotMatrix  = rx * ry * rz;
	    mat3 camIrotMatrix = inverse(camRotMatrix);
	    
		vec3 dir;
		vec2 cps = (v_vTexcoord - .5) * 2.;
		cps.x *= camRatio;
    		  
    	if(ortho == 0) {
		    float dz  = 1. / tan(radians(fov) / 2.);
		    dir = vec3(cps, -dz);
		    
	    } else if(ortho == 1) {
	    	dir = vec3(0., 0., -1.);
	    }
	    
	    dir  = normalize(camIrotMatrix * dir);
	    
	    vec2 envUV = equirectangularUv(dir);
		vec4 endC  = sampleTexture(0, envUV, envFilter);
		bg = endC;
	}
	
	vec4 result = drawBg == 1? bg : vec4(0.);
	     result = blend(result, scene());
	
    //////////////////////////////////////////////////
    
    gl_FragColor = result;
}