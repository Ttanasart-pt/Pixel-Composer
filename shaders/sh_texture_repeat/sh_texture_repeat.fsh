// Tiling algorithms
// Copyright © 2015 Inigo Quilez

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2      dimension;
uniform vec2      surfaceDimension;
uniform sampler2D surface;
uniform int       type;
uniform float     seed;

vec4 hash4( vec2 p ) { return fract(sin(vec4( 1.0 + seed + dot(p, vec2(37.0, 17.0)), 
                                              2.0 + seed + dot(p, vec2(11.0, 47.0)),
                                              3.0 + seed + dot(p, vec2(41.0, 29.0)),
                                              4.0 + seed + dot(p, vec2(23.0, 31.0)))) * 103.0); }
    
vec4 randomSample( in vec2 uv ) {
    vec2 iuv = floor( uv );
    vec2 fuv = fract( uv );
    
    vec4 ofa = hash4( iuv + vec2(0.0, 0.0) );
    vec4 ofb = hash4( iuv + vec2(1.0, 0.0) );
    vec4 ofc = hash4( iuv + vec2(0.0, 1.0) );
    vec4 ofd = hash4( iuv + vec2(1.0, 1.0) );
    
    // transform per-tile uvs
    ofa.zw = vec2(sign(ofa.zw - 0.5));
    ofb.zw = vec2(sign(ofb.zw - 0.5));
    ofc.zw = vec2(sign(ofc.zw - 0.5));
    ofd.zw = vec2(sign(ofd.zw - 0.5));
    
    // uv's, and derivarives (for correct mipmapping)
    vec2 uva = uv * ofa.zw + ofa.xy;
    vec2 uvb = uv * ofb.zw + ofb.xy;
    vec2 uvc = uv * ofc.zw + ofc.xy;
    vec2 uvd = uv * ofd.zw + ofd.xy;
    
    // fetch and blend
    vec2 b = smoothstep(0.25, 0.75, fuv);
    
    return mix( mix( texture2D( surface, fract(uva) ), 
                     texture2D( surface, fract(uvb) ), b.x ), 
                mix( texture2D( surface, fract(uvc) ),
                     texture2D( surface, fract(uvd) ), b.x), b.y );
}

vec3 cellSample( in vec2 uv, float v ) {
    vec2 p = floor( uv );
    vec2 f = fract( uv );
	
	vec3 va  = vec3(0.0);
	float w1 = 0.0;
    float w2 = 0.0;
    
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ ) {
        
        vec2 g  = vec2( float(i), float(j) );
		vec4 o  = hash4( p + g );
		vec2 r  = g - f + o.xy;
		float d = dot(r, r);
        float w = exp(-5.0 * d );
        vec3 c  = texture2D( surface, fract(uv + v * o.zw) ).xyz;
        
		va += w * c;
		w1 += w;
        w2 += w * w;
    }
    
    return va / w1;
}

float sum( vec3 v ) { return v.x + v.y + v.z; }

vec3 onionSample( in vec2 x, float v ) {
    float k = hash4( x * 0.005 ).x;
    
    float l = k * 8.0;
    float f = fract(l);
    
    float ia = floor(l); // my method
    float ib = ia + 1.0;
    
    vec2 offa = sin(vec2(3.0, 7.0) * ia); // can replace with any other hash
    vec2 offb = sin(vec2(3.0, 7.0) * ib); // can replace with any other hash
    
    vec3 cola = texture2D( surface, fract(x + v * offa) ).xyz;
    vec3 colb = texture2D( surface, fract(x + v * offb) ).xyz;
    
    return mix( cola, colb, smoothstep(0.2, 0.8, f - 0.1 * sum(cola - colb)) );
}

void main() {
    vec2 surfRat = dimension / surfaceDimension;
    vec2 posRat  = v_vTexcoord * surfRat;
    
         if(type == 0) gl_FragColor = texture2D( surface, fract(posRat) );
    else if(type == 1) gl_FragColor = randomSample( posRat );
    else if(type == 2) gl_FragColor = vec4(cellSample( posRat, 4. ), 1.);
    else if(type == 3) gl_FragColor = vec4(onionSample( posRat, 4. ), 1.);
}
