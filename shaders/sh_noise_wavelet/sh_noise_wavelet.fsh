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
uniform float progress;
uniform float detail;
uniform vec2  u_resolution;
uniform vec2  position;
uniform vec2  scale;

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
	vec2 pos    = v_vTexcoord - .5;
	     pos.x *= (u_resolution.x / u_resolution.y);
         pos    = (pos + position) * scale / 16.;
	
    vec3 col  = vec3(0.);
	     col += WaveletNoise(pos * 5., (2.9864 + progress), detail) * .5 + .5; 
	
    gl_FragColor = vec4(col, 1.0);
}