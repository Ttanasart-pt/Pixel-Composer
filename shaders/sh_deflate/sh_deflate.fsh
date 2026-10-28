varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D original;

uniform vec2  dimension;
uniform float amount;

void main() {
	vec4  baseS = texture2D(gm_BaseTexture, v_vTexcoord);
	vec4  orig  = v_vColour * texture2D(original, v_vTexcoord);
	
	gl_FragColor = orig;
	if(baseS.g < .5) return;
	
	if(baseS.r > amount) 
		gl_FragColor = vec4(0.);
}