varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D mask;
uniform float threshold;

void main() {
	vec4 cc = texture2D(gm_BaseTexture, v_vTexcoord);
	vec4 mm = texture2D(mask, v_vTexcoord);
	float v = (mm.r + mm.g + mm.b) / 3. * mm.a;
	
	gl_FragData[0] = vec4(0.);
	gl_FragData[1] = vec4(0.);
	
	if(v < threshold) gl_FragData[0] = cc;
	else gl_FragData[1] = cc;
}