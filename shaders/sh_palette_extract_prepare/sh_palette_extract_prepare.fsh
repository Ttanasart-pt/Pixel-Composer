varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D mask;
uniform int useMask;

uniform int multiplyAlpha;

void main() {
	vec4 base = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
	if(multiplyAlpha == 1) base.rgb *= base.a;
	if(useMask == 1) base *= texture2D(mask, v_vTexcoord);
	
	gl_FragColor = base;
}