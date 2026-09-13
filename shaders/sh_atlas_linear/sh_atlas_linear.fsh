varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float direction;
uniform int both;

void main() {
	vec2  tx  = 1. / dimension;
	float ang = radians(direction);
	
	vec2  stp = vec2(cos(ang), sin(ang)) * tx;
	vec4 base = texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = base * v_vColour;
	if(base.a > 0.) return;
	
	for(float i = 0.; i < dimension.x + dimension.y; i++) {
		vec4 smp = texture2D(gm_BaseTexture, v_vTexcoord + stp * i);
		if(smp.a > 0.) { gl_FragColor = smp; return; }
		
		if(both == 1) {
			vec4 smp = texture2D(gm_BaseTexture, v_vTexcoord - stp * i);
			if(smp.a > 0.) { gl_FragColor = smp; return; }
				
		}
	}
	
}