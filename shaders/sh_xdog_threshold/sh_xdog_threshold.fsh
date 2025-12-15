varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float epsilon;

void main() {
	vec4  samp = texture2D(gm_BaseTexture, v_vTexcoord);
	float ss = (samp.r + samp.g + samp.b) / 3. * samp.a;
	
	gl_FragColor.rgb = vec3(step(ss, epsilon));
	gl_FragColor.a   = 1.;
}