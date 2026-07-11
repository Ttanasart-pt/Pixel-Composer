varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform sampler2D raySurface;

void main() {
	vec4 base  = texture2D(gm_BaseTexture, v_vTexcoord);
	vec4 light = texture2D(raySurface, v_vTexcoord);
	
	light.a = max(light.a, 0.);
	light.rgb *= light.a;
	
	gl_FragColor = base + light;
}