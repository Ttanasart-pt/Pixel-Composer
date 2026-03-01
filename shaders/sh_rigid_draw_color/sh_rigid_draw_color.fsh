varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float index;

void main() {
	vec4 c = texture2D(gm_BaseTexture, v_vTexcoord);
	
	float ind = index * c.a;
	vec4  res = vec4(ind, ind, ind, c.a);
	gl_FragColor = res;
}