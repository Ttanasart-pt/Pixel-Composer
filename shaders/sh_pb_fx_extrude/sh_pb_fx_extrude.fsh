varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float angle;
uniform float extDistance;

uniform int   cloneColor;
uniform vec4  extColor;

uniform int   highlight;
uniform float highlightDir;
uniform vec4  highlightColor;

void main() {
	vec2 tx = 1. / dimension;
	vec4 cc = texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = cc;
	
	if(cc.a != 0.) {
		if(highlight == 1) {
			vec2 hig = vec2(cos(highlightDir), -sin(highlightDir));
			vec4 hsm = texture2D(gm_BaseTexture, v_vTexcoord + hig * tx);
			if(hsm.a == 0.) gl_FragColor = highlightColor;
		}
		
		return;
	}
	
	vec2 shf = vec2(cos(angle), -sin(angle));
	
	for(float i = 1.; i <= extDistance; i++) {
		vec4 sp = texture2D(gm_BaseTexture, v_vTexcoord - shf * i * tx);
		if(sp.a != 0.) { 
			cc = extColor; 
			if(cloneColor == 1) cc *= sp;
			break; 
		}
	}
	
	gl_FragColor = cc;
}