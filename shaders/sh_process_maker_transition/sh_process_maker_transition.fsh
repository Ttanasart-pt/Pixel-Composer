varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D prevSurf;
uniform int   type;
uniform float progress;

void main() {
	bool old = false;
	
	     if(type ==  1) old = (     v_vTexcoord.x + v_vTexcoord.y) / 2. > progress;
	else if(type ==  2) old = (1. - v_vTexcoord.x + v_vTexcoord.y) / 2. > progress;
	else if(type ==  3) old =       v_vTexcoord.x > progress;
	else if(type ==  4) old =       v_vTexcoord.y > progress;
	else if(type ==  5) old =  1. - v_vTexcoord.x > progress;
	else if(type ==  6) old =  1. - v_vTexcoord.y > progress;
	//               7
	else if(type ==  8) old =       length(v_vTexcoord - .5) / 1.4142135624 > progress;
	else if(type ==  9) old =  1. - length(v_vTexcoord - .5) / 1.4142135624 > progress;
	else if(type == 10) old =       max(abs(v_vTexcoord.x - .5), abs(v_vTexcoord.y - .5)) / .5 > progress;
	else if(type == 11) old =  1. - max(abs(v_vTexcoord.x - .5), abs(v_vTexcoord.y - .5)) / .5 > progress;
	else if(type == 12) old =       min(abs(v_vTexcoord.x - .5), abs(v_vTexcoord.y - .5)) / .5 > progress;
	else if(type == 13) old =  1. - min(abs(v_vTexcoord.x - .5), abs(v_vTexcoord.y - .5)) / .5 > progress;
	//              14
	else if(type == 15) { // fade
		vec4 c0 = texture2D(prevSurf, v_vTexcoord);
		vec4 c1 = texture2D(gm_BaseTexture, v_vTexcoord);
		gl_FragColor = mix(c0, c1, progress);
		return;
	} 
		
	else if(type == 16) { // morph
		vec4  c0 = texture2D(prevSurf, v_vTexcoord);
		vec4  c1 = texture2D(gm_BaseTexture, v_vTexcoord);
		float l1 = (c1.r + c1.g + c1.b) / 3.;
		gl_FragColor = l1 > progress? c0 : c1;
		return;
	}
	
	gl_FragColor = old? texture2D(prevSurf, v_vTexcoord) : texture2D(gm_BaseTexture, v_vTexcoord);
}