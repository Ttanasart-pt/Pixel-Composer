varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D insideSurf;

uniform vec2  dimension;
uniform int   highlight;
uniform float highlightDir;
uniform vec4  highlightColor;
uniform int   highlightAll;

void main() {
    vec2 tx = 1. / dimension;
	vec4 cc = texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = cc;
	
	bool hsm;
	
    if(highlight == 1) {
    	vec4 ins = texture2D(insideSurf, v_vTexcoord);
    	if(ins.a == 0.) return;
    	
    	if(highlightAll == 0) {
			vec2 hig = vec2(cos(highlightDir), -sin(highlightDir));
			hsm = texture2D(insideSurf, v_vTexcoord + hig * tx).a == 0.; if(hsm) gl_FragColor = highlightColor;
			
    	} else {
    		hsm = texture2D(insideSurf, v_vTexcoord + vec2(tx.x, 0.)).a == 0.; if(hsm) gl_FragColor = highlightColor;
			hsm = texture2D(insideSurf, v_vTexcoord - vec2(tx.x, 0.)).a == 0.; if(hsm) gl_FragColor = highlightColor;
			hsm = texture2D(insideSurf, v_vTexcoord + vec2(0., tx.y)).a == 0.; if(hsm) gl_FragColor = highlightColor;
			hsm = texture2D(insideSurf, v_vTexcoord - vec2(0., tx.y)).a == 0.; if(hsm) gl_FragColor = highlightColor;
    	}
	}
	
}