// Scratch noise by Peace
// Copyright (c) 2026 @Peace @lumiey
// https://www.shadertoy.com/view/7X2SWW

#ifdef _YY_HLSL11_
	#extension GL_OES_standard_derivatives : enable
#endif

#pragma use(uv)
#region -- uv -- [1779523757.7465837]
    uniform sampler2D uvMap;
    uniform int   useUvMap;
    uniform float uvMapMix;

    vec2 getUV(in vec2 uv) {
        if(useUvMap == 0) return uv;

        vec2 vuv   = texture2D( uvMap, uv ).xy;
             vuv.y = 1.0 - vuv.y;

        vec2 vtx = mix(uv, vuv, uvMapMix);
        return vtx;
    }
    
    vec2 getUVA(in vec2 uv, out float alpha) {
        if(useUvMap == 0) {
            alpha = 1.0;
            return uv;
        }

        vec4 samUV = texture2D( uvMap, uv );
        vec2 vuv = vec2(samUV.x, 1. - samUV.y);
        alpha    = samUV.a;

        vec2 vtx = mix(uv, vuv, uvMapMix);
        return vtx;
    }
#endregion -- uv --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

uniform vec2  position;
uniform float rotation;
uniform vec2  scale;

uniform float seed; 
uniform float thickness; //  0
uniform float wavyness;  // .5
uniform float softness;  //  3

uniform int   octaves;   //  8
uniform vec2  octaveShift;
uniform float octaveRotation;
uniform float octaveScale;

vec2 hash(vec2 p) { return fract(sin(vec2( dot(p, vec2(127.1324, 311.7874)) * (152.6178612 + seed / 10000.), 
										   dot(p, vec2(269.8355, 183.3961)) * (437.5453123 + seed / 10000.))) * 43758.5453); }

float scratch(vec2 p, float f) {
    vec2 i = floor(p);
    vec2 h = hash(i) * vec2(3104., 554.);
    
    p = (p - i) * 2.0 - 1.0;
    p = p * cos(h.x + h.y) + vec2(-p.y, p.x) * sin(h.x + h.y);
    p += sin(h.x - h.y);
    
    float x = abs(p.x - cos(h.x + p.y * 1.57) * wavyness);
    x = smoothstep(thickness + f, thickness - f, x);
    x *= p.y * 0.5 + 0.5;
    
    return x;
}

float scratches12(vec2 p) {
    float scratches = 0.0;
    float w = length(fwidth(p)) * softness;
    
    float ang = radians(octaveRotation);
    mat2  rot = mat2(cos(ang), -sin(ang), sin(ang), cos(ang));
    
    for(int i = 0; i < octaves; ++i) {
        float x = scratch(p, w);
    	scratches = max(scratches, x);
        p = p * rot - octaveShift;
        w *= octaveScale;
    }
    
    return scratches;
}

void main() {
	float a   = 0.;
	vec2  vtx = getUVA(v_vTexcoord, a);
	
	float ang = radians(rotation);
	vtx  = vtx * mat2(cos(ang), -sin(ang), sin(ang), cos(ang)) / scale;
	vtx -= position / dimension;
	
	float b   = scratches12(vtx);
	
	vec4 res = vec4(b,b,b,a);
	gl_FragColor = res;
}