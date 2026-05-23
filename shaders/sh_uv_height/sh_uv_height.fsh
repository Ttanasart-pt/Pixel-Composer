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

uniform sampler2D heightMap;
uniform vec2  dimension;
uniform vec2  position;
uniform float intensity;
uniform float blue;

void main() {
	vec2  tx  = 1. / dimension;
	vec2  ttx = v_vTexcoord - position / dimension;
	vec4  sam = texture2D(heightMap, getUV(fract(ttx)));
	float hg  = sam.x;
	float alp = sam.w;
	
    float dx = texture2D(heightMap, getUV(fract(ttx + vec2(tx.x, 0.)))).x - texture2D(heightMap, getUV(fract(ttx - vec2(tx.x, 0.)))).x;
    float dy = texture2D(heightMap, getUV(fract(ttx + vec2(0., tx.y)))).x - texture2D(heightMap, getUV(fract(ttx - vec2(0., tx.y)))).x;
    vec2  uv = vec2(v_vTexcoord.x, 1. - v_vTexcoord.y) + vec2(dx, dy) * intensity;

    gl_FragColor = vec4(uv, blue, alp);
}