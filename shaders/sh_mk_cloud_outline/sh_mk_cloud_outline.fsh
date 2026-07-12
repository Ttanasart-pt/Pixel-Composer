varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float thickness;
uniform vec4  color;

void main() {
	vec2 tx = 1. / dimension;
	vec4 base = texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = base;
	
	if(base.a > 0.) return;
	
	float astep = 64.;
	vec4 samp;
	
	if(thickness <= 0.) {
		samp = texture2D(gm_BaseTexture, v_vTexcoord + vec2(tx.x, 0.));
		if(samp.a > 0.) { gl_FragColor = color; return; }
		
		samp = texture2D(gm_BaseTexture, v_vTexcoord + vec2(0., tx.y));
		if(samp.a > 0.) { gl_FragColor = color; return; }
		
		samp = texture2D(gm_BaseTexture, v_vTexcoord - vec2(tx.x, 0.));
		if(samp.a > 0.) { gl_FragColor = color; return; }
		
		samp = texture2D(gm_BaseTexture, v_vTexcoord - vec2(0., tx.y));
		if(samp.a > 0.) { gl_FragColor = color; return; }
		
		return;
	}
	
	for(float i = 0.; i <= thickness; i++)
	for(float j = 0.; j < astep; j++) {
		float ang = radians(j / astep * 360.);
		vec2 offs = vec2(cos(ang), sin(ang)) * i * tx;
		
		samp = texture2D(gm_BaseTexture, v_vTexcoord + offs);
		if(samp.a > 0.) { gl_FragColor = color; return; }
	}
	
}