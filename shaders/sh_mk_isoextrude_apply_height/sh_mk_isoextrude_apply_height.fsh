varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int useHeight;
uniform sampler2D heightmap;
uniform sampler2D topmap;

uniform int useSide;
uniform sampler2D sideTexture;

uniform float maxDepth;
uniform float curDepth;

void main() {
	vec4 base = texture2D(gm_BaseTexture, v_vTexcoord) * v_vColour;
	float rh  = curDepth / maxDepth;
	float hh  = 1.;
	
	if(useHeight == 0) {
		gl_FragColor = base;
		
		if(curDepth == maxDepth)
			gl_FragColor = texture2D(topmap, v_vTexcoord);
		
	} else {
		gl_FragColor = vec4(0.);
		
		vec4 heig = texture2D(heightmap, v_vTexcoord);
		hh  = (heig.r + heig.g + heig.b) / 3. * heig.a;
		
		if(rh > hh) return;
		gl_FragColor = base;
	}
	
	if(useSide == 1) {
		vec2 sdUV = vec2(v_vTexcoord.x, rh);
		vec4 sCol = texture2D(sideTexture, sdUV) * v_vColour;
		gl_FragColor.rgb = sCol.rgb;
	}
	
	float nh  = (curDepth + 1.) / maxDepth;
	if(nh > hh) gl_FragColor = texture2D(topmap, v_vTexcoord);
}