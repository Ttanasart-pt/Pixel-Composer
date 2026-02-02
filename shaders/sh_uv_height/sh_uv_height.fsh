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
	vec2  tx = getUV(fract(v_vTexcoord - position / dimension));
    float hg = texture2D(heightMap, tx).x;
	
    float dx = dFdx(hg);
    float dy = dFdy(hg);
    vec2  uv = vec2(v_vTexcoord.x, 1. - v_vTexcoord.y) + vec2(dx, dy) * intensity;

    gl_FragColor = vec4(uv, blue, 1.);
}