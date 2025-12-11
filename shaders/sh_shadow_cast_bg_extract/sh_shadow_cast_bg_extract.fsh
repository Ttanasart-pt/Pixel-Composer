varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4  refColor;
uniform float threshold;

void main() {
	vec4 base = texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = vec4(0.);
	
	if(distance(base.rgb * base.a, refColor.rgb * refColor.a) >= threshold)
		gl_FragColor = vec4(1.);
}