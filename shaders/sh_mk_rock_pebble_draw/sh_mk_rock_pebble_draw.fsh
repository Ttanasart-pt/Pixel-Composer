varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float depth;

void main() {
	vec4 base = texture2D(gm_BaseTexture, v_vTexcoord);
	
	gl_FragData[0] = v_vColour * base;
	gl_FragData[1] = vec4(vec3(depth), base.a);
}