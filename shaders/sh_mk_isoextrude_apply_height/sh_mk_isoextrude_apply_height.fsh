varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int useHeight;
uniform sampler2D heightmap;
uniform sampler2D topmap;

uniform float maxDepth;
uniform float curDepth;

void main() {
	vec4 base = texture2D(gm_BaseTexture, v_vTexcoord) * v_vColour;
	
	if(useHeight == 0) {
		gl_FragColor = base;
		
		if(curDepth == maxDepth)
			gl_FragColor = texture2D(topmap, v_vTexcoord);
		return;
	}
	
	gl_FragColor = vec4(0.);
	
	vec4 heig = texture2D(heightmap, v_vTexcoord);
	float hh  = (heig.r + heig.g + heig.b) / 3. * heig.a;
	float rh  = curDepth / maxDepth;
	
	if(rh > hh) return;
	gl_FragColor = base;
	
	float nh  = (curDepth + 1.) / maxDepth;
	if(nh > hh) gl_FragColor = texture2D(topmap, v_vTexcoord);
}