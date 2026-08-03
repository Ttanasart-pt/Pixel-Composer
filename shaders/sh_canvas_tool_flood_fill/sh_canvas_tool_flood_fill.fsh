varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D baseSurface;
uniform vec2  dimension;
uniform vec4  baseColor;

uniform float threshold;
uniform int   diagonal;

void main() {
	vec2 tx = 1. / dimension;
	
	vec4 baseC = texture2D(baseSurface, v_vTexcoord);
	vec4 fillS = texture2D(gm_BaseTexture, v_vTexcoord);
	
	gl_FragColor = fillS;
	
	if(distance(baseC, baseColor) > threshold) return;
	
	vec4 f,s;
	float span = dimension[0] / 2.;
	
	for(float i = 1.; i <= span; i++) {
		vec2 px = v_vTexcoord + vec2(tx.x, 0.) * i;
		
		f = texture2D(gm_BaseTexture, px);
		s = texture2D(baseSurface,    px);
		
		if(distance(s, baseColor) > threshold) break;
		if(f.a > 0.) { gl_FragColor = vec4(1.); return; }
	}
	
	for(float i = 1.; i <= span; i++) {
		vec2 px = v_vTexcoord - vec2(tx.x, 0.) * i;
		
		f = texture2D(gm_BaseTexture, px);
		s = texture2D(baseSurface,    px);
		
		if(distance(s, baseColor) > threshold) break;
		if(f.a > 0.) { gl_FragColor = vec4(1.); return; }
	}
	
	for(float i = 1.; i <= span; i++) {
		vec2 px = v_vTexcoord + vec2(0., tx.y) * i;
		
		f = texture2D(gm_BaseTexture, px);
		s = texture2D(baseSurface,    px);
		
		if(distance(s, baseColor) > threshold) break;
		if(f.a > 0.) { gl_FragColor = vec4(1.); return; }
	}
	
	for(float i = 1.; i <= span; i++) {
		vec2 px = v_vTexcoord - vec2(0., tx.y) * i;
		
		f = texture2D(gm_BaseTexture, px);
		s = texture2D(baseSurface,    px);
		
		if(distance(s, baseColor) > threshold) break;
		if(f.a > 0.) { gl_FragColor = vec4(1.); return; }
	}
	
	if(diagonal == 0) return;
	
	for(float i = 1.; i <= span; i++) {
		vec2 px = v_vTexcoord + vec2(tx.x, tx.y) * i;
		
		f = texture2D(gm_BaseTexture, px);
		s = texture2D(baseSurface,    px);
		
		if(distance(s, baseColor) > threshold) break;
		if(f.a > 0.) { gl_FragColor = vec4(1.); return; }
	}
	
	for(float i = 1.; i <= span; i++) {
		vec2 px = v_vTexcoord + vec2(-tx.x, tx.y) * i;
		
		f = texture2D(gm_BaseTexture, px);
		s = texture2D(baseSurface,    px);
		
		if(distance(s, baseColor) > threshold) break;
		if(f.a > 0.) { gl_FragColor = vec4(1.); return; }
	}
	
	for(float i = 1.; i <= span; i++) {
		vec2 px = v_vTexcoord + vec2(tx.x, -tx.y) * i;
		
		f = texture2D(gm_BaseTexture, px);
		s = texture2D(baseSurface,    px);
		
		if(distance(s, baseColor) > threshold) break;
		if(f.a > 0.) { gl_FragColor = vec4(1.); return; }
	}
	
	for(float i = 1.; i <= span; i++) {
		vec2 px = v_vTexcoord + vec2(-tx.x, -tx.y) * i;
		
		f = texture2D(gm_BaseTexture, px);
		s = texture2D(baseSurface,    px);
		
		if(distance(s, baseColor) > threshold) break;
		if(f.a > 0.) { gl_FragColor = vec4(1.); return; }
	}
	
}