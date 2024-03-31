// The MIT License
// Copyright © 2013 Inigo Quilez
// https://www.youtube.com/c/InigoQuilez
// https://iquilezles.org/
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float seed;
uniform float progress;
uniform float paramA;
uniform vec2  u_resolution;
uniform vec2  position;
uniform float rotation;
uniform vec2  scale;
uniform int   mode;

float PI = 3.14159265359;
float s3 = sin(PI / 3.);

vec2 hash2( vec2 p ) { return fract(sin(vec2(dot(p, vec2(127.1 + seed, 311.7)), dot(p, vec2(269.5, 183.3 + seed)))) * 43758.5453); }

vec3 voronoi( in vec2 x ) { #region // IQ classic voronoi - shadertoy.com/view/ldl3W8
    vec2 ip = floor(x);
    vec2 fp = fract(x);

    //----------------------------------
    // first pass: regular voronoi
    //----------------------------------
	vec2 mg, mr;

    float md = 8.0;
    for( int j = -1; j <= 1; j++ )
    for( int i = -1; i <= 1; i++ ) {
        vec2 g = vec2(float(i), float(j));
		vec2 o = hash2( ip + g );
        o = 0.5 + 0.5 * sin( progress + 6.2831 * o );
        vec2 r = g + o - fp;
        float d = dot(r, r);
		
        if( d < md ) {
            md = d;
            mr = r;
            mg = g;
        }
    }
	
    //----------------------------------
    // second pass: distance to borders
    //----------------------------------
    md = 8.0;
    for( int j = -2; j <= 2; j++ )
    for( int i = -2; i <= 2; i++ ) {
        vec2 g = mg + vec2(float(i), float(j));
		vec2 o = hash2( ip + g );
        o = 0.5 + 0.5 * sin( progress + 6.2831 * o );
        vec2 r = g + o - fp;
		
        if( dot(mr - r, mr - r) > 0.00001 )
        md = min( md, dot( 0.5 * (mr + r), normalize(r - mr) ) );
    }
	
    return vec3( md, mr );
} #endregion 

vec3 squareVoronoi( in vec2 x ) { #region // IQ classic voronoi - shadertoy.com/view/ldl3W8
    vec2 ip = floor(x);
    vec2 fp = fract(x);

    //----------------------------------
    // first pass: regular voronoi
    //----------------------------------
	vec2 mg, mr;

    float md = 8.0;
    for( int j = -1; j <= 1; j++ )
    for( int i = -1; i <= 1; i++ ) {
        vec2 g = vec2(float(i), float(j));
		vec2 o = hash2( ip + g );
		
        o = 0.5 + 0.5 * sin( progress + 6.2831 * o );
        vec2 r = g + o * paramA - fp;
        float d = dot(r, r);
		
        if( d < md ) {
            md = d;
            mr = r;
            mg = g;
        }
    }
	
    //----------------------------------
    // second pass: distance to borders
    //----------------------------------
    md = 8.0;
    for( int j = -2; j <= 2; j++ )
    for( int i = -2; i <= 2; i++ ) {
        vec2 g = mg + vec2(float(i), float(j));
		vec2 o = hash2( ip + g );
        
		o = 0.5 + 0.5 * sin( progress + 6.2831 * o );
        vec2 r = g + o * paramA - fp;
		
        if( dot(mr - r, mr - r) > 0.00001 )
			md = min( md, dot( 0.5 * (mr + r), normalize(r - mr) ) );
    }
	
    return vec3( md, mr );
} #endregion 

#region // Fast Minimal Animated Blocks by Shane - shadertoy.com/view/MlVXzd
	float blockVoronoiDistanceMetrix(vec2 p) { 
	    p = fract(p) - .5;   
	    return max(abs(p.x) * (.866 + paramA) + p.y * .5, -p.y);
	}

	float blockVoronoi(vec2 p) { 
	    vec2 o  = sin(vec2(1.93, 0) + progress) * .166;
	    float a = blockVoronoiDistanceMetrix(p + vec2(o.x, 0));
		float b = blockVoronoiDistanceMetrix(p + vec2(0, .5 + o.y));
    
	    p = -mat2(.5, -.866, .866, .5) * (p + .5); // Rotate the layer (coordinates) by 120 degrees. 
	    float c = blockVoronoiDistanceMetrix(p + vec2(o.x, 0));
		float d = blockVoronoiDistanceMetrix(p + vec2(0, .5 + o.y)); 
    
	    return min(min(a, b), min(c, d)) * 2.;
	} 
#endregion

#region // Triangle Voronoi by tdhooper - shadertoy.com/view/Ns3fD7
	vec3 sdTriEdges(vec2 p) { return vec3(dot(p, vec2(0,-1)), dot(p, vec2(s3, .5)), dot(p, vec2(-s3, .5))); }

	float sdTri(vec2 p) { vec3 t = sdTriEdges(p); return max(t.x, max(t.y, t.z)); }
	
	vec3 triPrimaryAxis(vec3 p) { vec3 a = abs(p); return (1. - step(a.xyz, a.yzx)) * step(a.zxy, a.xyz) * sign(p); }
	
	float triPickComponent(vec3 v, vec3 mask) { v *= mask; return v.x + v.y + v.z; }
	
	float triangleBorder(vec2 a, vec2 b) {
	    vec3 ta = sdTriEdges(a);
	    vec3 tb = sdTriEdges(b);
    
	    vec3 tbRel  = sdTriEdges(b - a);    
	    vec3 axis   = triPrimaryAxis(tbRel);
		bool isEdge = axis.x + axis.y + axis.z < 0.;
		float d;
    
	    if (isEdge) {
	        float i = triPickComponent(ta, axis);
	        float j = triPickComponent(tb, axis.zxy);
	        float k = triPickComponent(tb, axis.yzx);
	        d = max(i - j, i - k);
	    } else {
	        float i = triPickComponent(tb, axis);
	        float j = triPickComponent(ta, axis.zxy);
	        float k = triPickComponent(ta, axis.yzx);
	        d = min(i - j, i - k);
	    }
    
	    d /= s3 * 2.;
    
	    return abs(d);
	}
	
	vec3 triangleVoronoi( in vec2 x ) {
	    vec2 n = floor(x);
	    vec2 f = fract(x);

	    //----------------------------------
	    // first pass: regular voronoi
	    //----------------------------------
		vec2 closestCell, closestPoint;
	    const int reach = 2;

	    float closestDist = 8.0;
	    for( int j = -reach; j <= reach; j++ )
	    for( int i = -reach; i <= reach; i++ ) {
	        vec2 cell = vec2(float(i),float(j));
			vec2 o = hash2( n + cell );
			
	        o = 0.5 + 0.5 * sin( progress * PI * 2. + 6.2831 * o );
	        
	        vec2 point = cell + o - f;
	        float dist = sdTri(point);

	        if( dist < closestDist ) {
	            closestDist  = dist;
	            closestPoint = point;
	            closestCell  = cell;
	        }
	    }
		
	    //----------------------------------
	    // second pass: distance to borders
	    //----------------------------------
	    closestDist = 8.0;
	    for( int j = -reach - 1; j <= reach + 1; j++ )
	    for( int i = -reach - 1; i <= reach + 1; i++ ) {
	        vec2 cell = closestCell + vec2(float(i), float(j));
			vec2 o = hash2( n + cell );
			
	        o = 0.5 + 0.5 * sin( progress * PI * 2. + 6.2831 * o );
	        
	        vec2 point = cell + o - f;
			float dist = sdTri(closestPoint - point);

	        if( dist > 0.00001 )
				closestDist = min(closestDist, triangleBorder(closestPoint, point));
	    }

	    return vec3( closestDist, closestPoint );
	}
#endregion

void main() { #region
	
	float ang = radians(rotation);
    vec2 pos  = (v_vTexcoord - position / u_resolution) * mat2(cos(ang), -sin(ang), sin(ang), cos(ang)) * scale / 4.;
    
	if(mode == 0) {
		gl_FragColor = vec4(vec3(.1 + blockVoronoi(pos * vec2(1., -1.))), 1.0);
	} else if(mode == 1) {
		vec3 v = vec3(triangleVoronoi(pos * 2.));
		gl_FragColor = vec4(vec3(v.r), 1.0);
	} else if(mode == 2) {
		gl_FragColor = vec4(vec3(squareVoronoi(pos * 4.).r), 1.0);
	} 
} #endregion