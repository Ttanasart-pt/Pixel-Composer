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
uniform vec2  anchor;
uniform float rotation;
uniform vec2  tile;
uniform int   repeat;

uniform vec2  xRange;
uniform vec2  yRange;
uniform float blue;

void main() {
	float ang = radians(rotation);
	
	vec2 vtx  = getUV(v_vTexcoord);
	     vtx -= position / dimension;
	     vtx *= mat2(cos(ang), -sin(ang), sin(ang), cos(ang));
		 vtx *= tile;
		 vtx -= anchor;
		 
	     if(repeat == 0) vtx  = clamp(vtx, 0., 1.);
	else if(repeat == 1) vtx  = fract(fract(vtx) + 1.);
	
	float x = mix(xRange[0], xRange[1], vtx.x);
	float y = mix(yRange[0], yRange[1], vtx.y);
	
	gl_FragColor = vec4(x, 1. - y, blue, 1.);
}