// The MIT License
// Copyright © 2015 Inigo Quilez
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// https://www.youtube.com/c/InigoQuilez
// https://iquilezles.org

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D surface;
uniform float blend;
uniform vec2  scale;

vec4 hash4( vec2 p ) { return fract(sin(vec4( 1.0 + dot(p, vec2(37.0, 17.0)), 
                                              2.0 + dot(p, vec2(11.0, 47.0)),
                                              3.0 + dot(p, vec2(41.0, 29.0)),
                                              4.0 + dot(p, vec2(23.0, 31.0)))) * 103.0); }

vec4 textureNoTile( in vec2 uv, float v ) {
    vec2 p = floor( uv );
    vec2 f = fract( uv );
	
	vec4  va = vec4(0.0);
	float w1 = 0.0;
    float w2 = 0.0;
	
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ ) {
        vec2  g = vec2( float(i), float(j) );
		vec4  o = hash4( p + g );
		vec2  r = g - f + o.xy;
		float d = dot(r, r);
        float w = exp(-5.0 * d );
        vec4  c = texture2D( surface, fract(uv + v * o.zw) );
		
		va += w * c;
		w1 += w;
        w2 += w * w;
    }
    
    float mean = 0.3;
    vec4  res  = mean + (va - w1 * mean) / sqrt(w2);
    return mix( va / w1, res, v );
}

void main() {
	vec2 uv = v_vTexcoord * scale;
	
    gl_FragColor = textureNoTile( uv, blend );
}
