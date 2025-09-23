varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D surface0;
uniform sampler2D surface1;
uniform sampler2D depth0;
uniform sampler2D depth1;

void main() {
	vec4 s0 = texture2D( surface0, v_vTexcoord );
	vec4 s1 = texture2D( surface1, v_vTexcoord );
	vec4 d0 = texture2D( depth0,   v_vTexcoord );
	vec4 d1 = texture2D( depth1,   v_vTexcoord );
	
	vec4 bg = d0.x > d1.x? s1 : s0;
	vec4 fg = d0.x > d1.x? s0 : s1;
	gl_FragColor = bg * (1. - fg.a) + fg * fg.a;
}