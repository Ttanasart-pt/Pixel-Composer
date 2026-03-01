varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float index;

void main() {
	vec4 c = texture2D(gm_BaseTexture, v_vTexcoord);
	
	vec4 res = vec4(index * c.a, 0., 0., 1.);
	gl_FragColor = res;
}