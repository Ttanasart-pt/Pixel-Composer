varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float rotation;

float d(vec4 c) { return (c.r + c.g + c.b) / 3. * c.a; }

void main() {
	vec2 tx = 1. / dimension;
	vec4 cc = texture2D( gm_BaseTexture, v_vTexcoord );
	int emp = 0;
	
	vec2 px = v_vTexcoord * dimension;
	
	gl_FragColor = vec4(0.);
	
	if(d(cc) > 0.) {
		float ang = radians(rotation);
		vec2  sx  = vec2(cos(ang), -sin(ang)) * tx;
		vec4  c;
		
		for(float i = 1.; i <= 1.; i++) {
			vec2 ss = v_vTexcoord + sx * float(i);
			
			c = texture2D( gm_BaseTexture, ss );
			if(d(c) == 0.) emp++;
			else           break;
		}
	}
	
	if(emp >= 1) gl_FragColor = cc;
}
