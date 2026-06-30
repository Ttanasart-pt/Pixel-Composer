varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float angle;

void main() {
	vec2 tx = 1. / dimension;
	vec4 base = texture2D(gm_BaseTexture, v_vTexcoord);
	
	float ang = radians(angle);
	vec2  ttx = .5 + (v_vTexcoord - .5) * mat2(cos(ang), -sin(ang), sin(ang), cos(ang));
	
	if(ttx.x > .5) base.rgb *= .8;
	
	gl_FragColor = base;
}