varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float density;
uniform float seed;

float random (in vec2 st, float seed) { return fract(sin(dot(st.xy + seed / 1000., vec2(1892.9898, 78.23453))) * 437.54123); }

void main() {
	vec2  px    = floor(v_vTexcoord * dimension);
	vec4  grass = texture2D(gm_BaseTexture, v_vTexcoord);
	
	gl_FragColor = vec4(0.);
	
	if(mod(px.x + px.y, 2.) == 0.) return;
	if(random(px, seed) > density) return;
	
	if(grass.r > 0. && grass.g > .5)
		gl_FragColor = grass;
	
}