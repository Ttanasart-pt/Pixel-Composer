varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  rotationRandom;
uniform float seed;

float random (in vec2 st, float seed) { return fract(sin(dot(st.xy + seed / 1000., vec2(1892.9898, 78.23453))) * 437.54123); }

void main() {
    vec4 c = texture2D( gm_BaseTexture, v_vTexcoord );
    
	if(c.rgb == vec3(0.)) {
		gl_FragColor = vec4(0.);
		return;
	}
	
	vec2  t = (v_vTexcoord - c.xy) / (c.zw - c.xy);
	float r = mix(rotationRandom.x, rotationRandom.y, random(c.xy, seed));
	t = (t - .5) * mat2(cos(r), -sin(r), sin(r), cos(r)) + .5;
	
	gl_FragColor = vec4( t, 0., 1. );
}
