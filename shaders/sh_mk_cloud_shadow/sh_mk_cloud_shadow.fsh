varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float radius;
uniform float strength;
uniform vec4  color;

void main() {
	vec2 tx = 1. / dimension;
	vec4 base = texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = base;
	
	if(base.a > 0.) return;
	
	float astep = 64.;
	
	for(float i = 0.; i < radius; i++)
	for(float j = 0.; j < astep; j++) {
		float ang = radians(j / astep * 360.);
		vec2 offs = vec2(cos(ang), sin(ang)) * i * tx;
		
		vec4 samp = texture2D(gm_BaseTexture, v_vTexcoord + offs);
		if(samp.a > 0.) {
			float ints = 1. - i / radius;
			gl_FragColor = vec4(color.rgb, ints * strength);
			return;
		}
	}
	
}