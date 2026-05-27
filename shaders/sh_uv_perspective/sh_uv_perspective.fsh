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

uniform int   side;
uniform vec2  camPerspect;

uniform vec2      camDistance;
uniform int       camDistanceUseSurf;
uniform sampler2D camDistanceSurf;

uniform vec2  dimension;
uniform vec2  position;
uniform vec2  offset;
uniform vec2  anchor;
uniform float rotation;
uniform vec2  tile;
uniform int   repeat;
uniform int   invert;

uniform vec2  xRange;
uniform vec2  yRange;
uniform float blue;

mat2 inverse(mat2 m) {
    float det = m[0][0] * m[1][1] - m[0][1] * m[1][0];
    return mat2( m[1][1], -m[0][1], -m[1][0], m[0][0]) / det;
}

void main() {
	float cDis = camDistance.x;
	if(camDistanceUseSurf == 1) {
		vec4 _vMap = texture2D( camDistanceSurf, v_vTexcoord );
		cDis = mix(camDistance.x, camDistance.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float ang = radians(rotation);
	float uva;
	
	vec2  vtx = getUVA(v_vTexcoord, uva);
    float camDist = 0.;
    vec2  camAnch = vec2(0.);
    
    vtx -= offset / dimension;
    vtx -= anchor;
    vtx *= mat2(cos(ang), -sin(ang), sin(ang), cos(ang));
    
    if(side == 0) {
	    camDist = vtx.y * cDis;
	    camAnch = vec2(.5, 0.);
	    
    } else if(side == 1) {
	    camDist = vtx.x * cDis;
	    camAnch = vec2(0., .5);
	    
    } else if(side == 2) {
	    camDist = 1. - vtx.y * cDis;
	    camAnch = vec2(.5, 0.);
	    
    } else if(side == 3) {
	    camDist = 1. - vtx.x * cDis;
	    camAnch = vec2(0., .5);
    }
	
    vtx = camAnch + (vtx - camAnch) * 2. / (1. + camDist * camPerspect);
    
    vtx -= position / dimension;
    vtx *= tile;
    vtx += anchor;
		 
	if(repeat == 0) { if(vtx.x < 0. || vtx.y < 0. || vtx.x >= 1. || vtx.y >= 1.) discard; }
	else if(repeat == 1) vtx  = fract(fract(vtx) + 1.);
	else if(repeat == 2) vtx  = clamp(vtx, 0., 1.);
	else if(repeat == 3) vtx  = 1. - abs(fract(fract(vtx / 2.) + 1.) - .5) * 2.;
	
	float x = mix(xRange[0], xRange[1], vtx.x);
	float y = mix(yRange[0], yRange[1], vtx.y);
	
	gl_FragColor = vec4(x, y, blue, uva);
}