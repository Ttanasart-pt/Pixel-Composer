varying vec4 v_vColour;
varying vec4 v_vPos;

uniform vec2  worldPos;
uniform float direction;
uniform float dott;
uniform float dottShift;

void main() {
	vec2 tx = v_vPos.xy - worldPos;
	
	float linePrg = dot(tx, vec2(cos(direction), -sin(direction)));
	float dottPrg = linePrg - dottShift;
	float dashAmo = mod(dottPrg, dott) / dott;
	
	gl_FragColor = vec4(0.);
	if(dashAmo > .5) gl_FragColor = v_vColour;
}