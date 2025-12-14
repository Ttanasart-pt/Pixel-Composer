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

// "Wavelet Noise" 
// The MIT License
// Copyright © 2020 Martijn Steinrucken
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// Email: countfrolic@gmail.com
// Twitter: @The_ArtOfCode
// YouTube: youtube.com/TheArtOfCodeIsCool
// Facebook: https://www.facebook.com/groups/theartofcode/

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float seed;
uniform vec2  dimension;
uniform vec2  position;
uniform float rotation;

uniform vec2      progress;
uniform int       progressUseSurf;
uniform sampler2D progressSurf;

uniform vec2      detail;
uniform int       detailUseSurf;
uniform sampler2D detailSurf;

uniform vec2      scale;
uniform int       scaleUseSurf;
uniform sampler2D scaleSurf;

float WaveletNoise(vec2 p, float z, float k) {
    float d = 0., s = 1., m = 0., a;
	
    for(float i = 0.; i < 4.; i++) {
        vec2 q = p * s;
		vec2 g = fract(floor(q) * vec2(123.34 + seed, 233.53 + seed));
		
    	g += dot(g, g + 23.234);
		a = fract(g.x * g.y) * 0.0001 + z * (mod(g.x + g.y, 2.) - 1.); // add vorticity
        q = (fract(q) - .5) * mat2(cos(a), -sin(a), sin(a), cos(a));
        d += sin(q.x * 10. + z) * smoothstep(.25, .0, dot(q, q)) / s;
        p = p * mat2(.54, -.84, .84, .54) + i;
        m += 1. / s;
        s *= k; 
    }
    return d / m;
}

void main() {
	#region params
		vec2 sca = scale;
		if(scaleUseSurf == 1) {
			vec4 _vMap = texture2D( scaleSurf, v_vTexcoord );
			sca = vec2(mix(scale.x, scale.y, (_vMap.r + _vMap.g + _vMap.b) / 3.));
		}
		
		float prog = progress.x;
		if(progressUseSurf == 1) {
			vec4 _vMap = texture2D( progressSurf, v_vTexcoord );
			prog = mix(progress.x, progress.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float detl = detail.x;
		if(detailUseSurf == 1) {
			vec4 _vMap = texture2D( detailSurf, v_vTexcoord );
			detl = mix(detail.x, detail.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
	#endregion
	
	vec2  vtx = getUV(v_vTexcoord);
	vec2  ntx = vtx * vec2(1., dimension.y / dimension.x);
	float ang = radians(rotation);
    vec2  pos = (ntx - position / dimension) * mat2(cos(ang), -sin(ang), sin(ang), cos(ang)) * sca / 16.;
    
    vec3 col  = vec3(0.);
	     col += WaveletNoise(pos * 5., (2.9864 + prog), detl) * .5 + .5; 
	
    gl_FragColor = vec4(col, 1.0);
}