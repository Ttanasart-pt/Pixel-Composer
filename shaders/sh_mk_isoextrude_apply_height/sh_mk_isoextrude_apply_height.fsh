varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float maxDepth;
uniform float curDepth;

uniform float rotation;

uniform int useHeight;
uniform sampler2D heightmap;
uniform sampler2D topmap;
uniform sampler2D coordMap;

uniform int useSide;
uniform sampler2D sideTexture;

uniform int holeType;
uniform int useHole1;
uniform sampler2D holeTexture1;

uniform int useHole2;
uniform sampler2D holeTexture2;

void main() {
	vec4 base = texture2D(gm_BaseTexture, v_vTexcoord) * v_vColour;
	vec4 cord = texture2D(coordMap, v_vTexcoord);
	float rh  = curDepth / maxDepth;
	float hh  = 1.;
	
	gl_FragData[1] = vec4(0.);
	
	if(useHeight == 0) {
		gl_FragData[0] = base;
		if(curDepth == maxDepth)
			gl_FragData[0] = texture2D(topmap, v_vTexcoord);
		
		if(base.a > 0.) gl_FragData[1] = vec4(vec3(rh), 1.);
		
	} else {
		gl_FragData[0] = vec4(0.);
		
		vec4 heig = texture2D(heightmap, v_vTexcoord);
		hh  = (heig.r + heig.g + heig.b) / 3. * heig.a;
		
		if(rh > hh) return;
		gl_FragData[0] = base;
		if(base.a > 0.) gl_FragData[1] = vec4(vec3(rh), 1.);
	}
	
	if(useSide == 1) {
		vec2 sdUV = vec2(fract(fract(v_vTexcoord.x - rotation) + 1.), 1. - rh);
		vec4 sCol = texture2D(sideTexture, sdUV) * v_vColour;
		gl_FragData[0].rgb = sCol.rgb;
		gl_FragData[0].a  *= sCol.a;
	}
	
	float nh  = (curDepth + 1.) / maxDepth;
	if(nh > hh) gl_FragData[0] = texture2D(topmap, v_vTexcoord);
	
	bool h1 = false;
	bool h2 = false;
	
	if(useHole1 == 1) {
		vec4 h = texture2D(holeTexture1, vec2(cord.x, 1. - rh));
		h1 = h.a == 0.;
	}
	
	if(useHole2 == 1) {
		vec4 h = texture2D(holeTexture2, vec2(cord.y, 1. - rh));
		h2 = h.a == 0.;
	}
	
	if(holeType == 0) {
		if(h1 || h2) {
			gl_FragData[0].a = 0.;
			gl_FragData[1].a = 0.;
		}
		
	} else if(holeType == 1) {
		if(h1 && h2) {
			gl_FragData[0].a = 0.;
			gl_FragData[1].a = 0.;
		}
		
	}
}