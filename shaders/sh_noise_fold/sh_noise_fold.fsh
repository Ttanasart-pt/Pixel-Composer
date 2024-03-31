// Based on FabriceNeyret2 - plop 2 shader

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  u_resolution;
uniform vec2  position;
uniform float rotation;
uniform vec2  scale;

uniform int   iteration;
uniform float stretch;
uniform float amplitude;

uniform int   mode;

void main() {
	float ang = radians(rotation);
    vec2 pos  = (v_vTexcoord - position / u_resolution) * mat2(cos(ang), -sin(ang), sin(ang), cos(ang)) * scale;
	vec4 col  = vec4(0., 0., 0., 1.);
	
    for (int i = 0; i < iteration; i++) {
    	pos += cos( pos.yx * 3. + vec2(0.0, stretch)) / 3.;
        pos += sin( pos.yx      + vec2(stretch, 0.0)) / 2.;
        pos *= amplitude;
    }
    
	if(mode == 0) col += length(mod(pos, 2.) - 1.);
	else          col.xy += abs(mod(pos, 2.) - 1.);
	
    gl_FragColor = col;
}
