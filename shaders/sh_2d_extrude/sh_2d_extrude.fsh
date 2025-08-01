varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float angle;
uniform float extDistance;
uniform int   wrap;

void main() {
	vec2 tx = 1. / dimension;
	vec4 cc = texture2D(gm_BaseTexture, v_vTexcoord);
	
	gl_FragColor = vec4(0.);
	if(cc.a != 0.) { gl_FragColor = vec4(-1.); return; }
	
	vec2 shf = vec2(cos(angle), -sin(angle)) * tx;
	
	for(float i = 1.; i <= extDistance; i++) {
		vec2 px = v_vTexcoord - shf * i;
		if(wrap == 1) px = fract(fract(px) + 1.);
		
		vec4 sp = texture2D(gm_BaseTexture, px);
		if(sp.a != 0.) { gl_FragColor = vec4(i, px, 1.); return; }
	}
	
}