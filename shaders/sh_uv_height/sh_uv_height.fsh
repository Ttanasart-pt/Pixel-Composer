#ifdef _YY_HLSL11_
	#extension GL_OES_standard_derivatives : enable
#endif

#pragma use(uv)

#region -- uv -- [1765685937.0825768]
    uniform sampler2D uvMap;
    uniform int   useUvMap;
    uniform float uvMapMix;

    vec2 getUV(in vec2 uv) {
        if(useUvMap == 0) return uv;

        vec2 vtx = mix(uv, texture2D( uvMap, uv ).xy, uvMapMix);
        vtx.y = 1.0 - vtx.y;
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
	float hg  = texture2D(heightMap, getUV(fract(ttx))).x;
	
    float dx = texture2D(heightMap, getUV(fract(ttx + vec2(tx.x, 0.)))).x - texture2D(heightMap, getUV(fract(ttx - vec2(tx.x, 0.)))).x;
    float dy = texture2D(heightMap, getUV(fract(ttx + vec2(0., tx.y)))).x - texture2D(heightMap, getUV(fract(ttx - vec2(0., tx.y)))).x;
    vec2  uv = vec2(v_vTexcoord.x, 1. - v_vTexcoord.y) + vec2(dx, dy) * intensity;

    gl_FragColor = vec4(uv, blue, 1.);
}