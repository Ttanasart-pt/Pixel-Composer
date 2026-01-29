varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float threshold;
uniform vec4  bgColor;

void main() {
	vec4 base = texture2D(gm_BaseTexture, v_vTexcoord);
	if(base.a <= threshold) {
		gl_FragColor = vec4(0.);
		return;
	}
	
	base.rgb = mix(base.rgb, base.rgb * bgColor.rgb, 1. - base.a);
	base.a   = 1.;
	gl_FragColor = base;
}