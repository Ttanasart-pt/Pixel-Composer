varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D mask;
uniform float threshold;

bool masked(vec4 col) {
	float v = (col.r + col.g + col.b) / 3. * col.a;
	return v < threshold;
}

void main() {
	gl_FragData[0] = vec4(0.);
	gl_FragData[1] = vec4(0.);
	
	vec4 cc = texture2D(gm_BaseTexture, v_vTexcoord);
	vec4 mm = texture2D(mask, v_vTexcoord);
	
	if(masked(mm)) gl_FragData[0] = cc;
	else gl_FragData[1] = cc;
}