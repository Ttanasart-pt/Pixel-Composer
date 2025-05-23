varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D baseSurface;
uniform vec2  dimension;
uniform vec4  baseColor;
uniform float threshold;
uniform int   region;

bool colorMatch(vec4 c1, vec4 c2) { return distance(c1.rgb * c1.a, c2.rgb * c2.a) <= threshold; }

void main() {
	vec2 tx = 1. / dimension;
	
	vec4 filled  = texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = filled;
	if(filled.a == 1.) return;
	
	vec4 currColor = texture2D(baseSurface, v_vTexcoord);
	if(!colorMatch(baseColor, currColor)) return;
	
	if(region == 0) { gl_FragColor = vec4(1.); return; }
	
	for(float i = 1.; i < 4.; i++) {
		vec2 samPos = v_vTexcoord + vec2(tx.x, 0.) * i;
		vec4 samCol = texture2D(baseSurface, samPos);
		if(!colorMatch(baseColor, samCol)) break;
		
		vec4 samFil = texture2D(gm_BaseTexture, samPos);
		if(samFil.a == 1.) { gl_FragColor = vec4(1.); return; }
	}
	
	for(float i = 1.; i < 4.; i++) {
		vec2 samPos = v_vTexcoord + vec2(-tx.x, 0.) * i;
		vec4 samCol = texture2D(baseSurface, samPos);
		if(!colorMatch(baseColor, samCol)) break;
		
		vec4 samFil = texture2D(gm_BaseTexture, samPos);
		if(samFil.a == 1.) { gl_FragColor = vec4(1.); return; }
	}
	
	for(float i = 1.; i < 4.; i++) {
		vec2 samPos = v_vTexcoord + vec2(0., tx.y) * i;
		vec4 samCol = texture2D(baseSurface, samPos);
		if(!colorMatch(baseColor, samCol)) break;
		
		vec4 samFil = texture2D(gm_BaseTexture, samPos);
		if(samFil.a == 1.) { gl_FragColor = vec4(1.); return; }
	}
	
	for(float i = 1.; i < 4.; i++) {
		vec2 samPos = v_vTexcoord + vec2(0., -tx.y) * i;
		vec4 samCol = texture2D(baseSurface, samPos);
		if(!colorMatch(baseColor, samCol)) break;
		
		vec4 samFil = texture2D(gm_BaseTexture, samPos);
		if(samFil.a == 1.) { gl_FragColor = vec4(1.); return; }
	}
	
}