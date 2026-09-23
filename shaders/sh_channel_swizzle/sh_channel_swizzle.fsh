varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int red;
uniform int green;
uniform int blue;
uniform int alpha;

void main() {
	vec4 samp = texture2D(gm_BaseTexture, v_vTexcoord);
	vec4 outp = vec4(0.);
	
	outp.r = red   >= 10? float(red   - 10) : samp[red];
	outp.g = green >= 10? float(green - 10) : samp[green];
	outp.b = blue  >= 10? float(blue  - 10) : samp[blue];
	outp.a = alpha >= 10? float(alpha - 10) : samp[alpha];
	
	gl_FragColor = outp * v_vColour;
}