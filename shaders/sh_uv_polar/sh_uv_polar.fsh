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

uniform vec2  dimension;
uniform vec2  position;
uniform float rotation;
uniform vec2  tile;

uniform vec2  xRange;
uniform vec2  yRange;
uniform float blue;

uniform int   invert;

const float PI = 3.14159265358979323846;

void main() {
	float ang = radians(rotation);
	
	vec2 vtx  = getUV(v_vTexcoord);
	     vtx -= position / dimension;
	     vtx *= mat2(cos(ang), -sin(ang), sin(ang), cos(ang));
	     
	float a	= (atan(vtx.y, -vtx.x) + PI) / (PI * 2.);
	float r = length(vtx) / (sqrt(2.) * .5);
	
	a = fract(fract(a * tile.x) + 1.);
	r = fract(fract(r * tile.y) + 1.);
	
	float x = mix(xRange[0], xRange[1], a);
	float y = mix(yRange[0], yRange[1], r);
	
	gl_FragColor = invert == 0? vec4(x, y, blue, 1.) : vec4(y, x, blue, 1.);
}