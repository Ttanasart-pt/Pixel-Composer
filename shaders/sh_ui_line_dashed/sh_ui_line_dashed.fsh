varying vec4 v_vColour;
varying vec4 v_vPos;

uniform vec2  worldPos;
uniform float dash;
uniform float dashShift;

void main() {
	vec2 tx = v_vPos.xy - worldPos;
	
	float dashPrg = tx.x + tx.y + dashShift;
	float dashAmo = mod(dashPrg, dash * 2.) / (dash * 2.);
	
	gl_FragColor = vec4(0.);
	if(dashAmo > .5) gl_FragColor = v_vColour;
}