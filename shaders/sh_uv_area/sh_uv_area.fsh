#pragma use(uv)

#region -- uv -- [1770002023.9166503]
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
#endregion -- uv --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;

uniform float area[6];
uniform int   invert;

uniform float rotation;
uniform vec2  tile;
uniform int   repeat;

uniform vec2  xRange;
uniform vec2  yRange;
uniform float blue;

void main() {
	float ang = radians(rotation);
	
	vec2 xy = vec2(area[0], area[1]) / dimension;
	vec2 wh = vec2(area[2], area[3]) / dimension;
	
	xy -= wh;
	wh *= 2.;
	
	vec2 vtx  = getUV(v_vTexcoord);
	
	if(invert == 0) { 
		vtx -= xy;
		vtx /= wh;
	     
	} else { 
		vtx *= wh;
		vtx += xy;
	}
	
	vtx *= mat2(cos(ang), -sin(ang), sin(ang), cos(ang));
	vtx *= tile;
		 
	if(repeat == 0) { if(vtx.x < 0. || vtx.y < 0. || vtx.x >= 1. || vtx.y >= 1.) discard; }
	else if(repeat == 1) vtx  = fract(fract(vtx) + 1.);
	else if(repeat == 2) vtx  = clamp(vtx, 0., 1.);
	else if(repeat == 3) vtx  = 1. - abs(fract(fract(vtx / 2.) + 1.) - .5) * 2.;
	
	float x = mix(xRange[0], xRange[1], vtx.x);
	float y = mix(yRange[0], yRange[1], vtx.y);
	
	gl_FragColor = vec4(x, y, blue, 1.);
}