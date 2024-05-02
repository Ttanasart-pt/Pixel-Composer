//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int diagonal;

#define TAU 6.283185307179586

void main() {
	vec4 red = vec4(1., 0., 0., 1.);
	vec4 c = texture2D( gm_BaseTexture, v_vTexcoord );
	gl_FragColor = c;
	
	if(c.rgb == vec3(0.)) return;
	if(c == red) return;
	
	float ite  = diagonal == 1? 8. : 4.;
	float base = 1.;
	float top  = 0.;
	vec2  shf  = vec2(0.);
	vec2  tx   = 1. / dimension;
	
	for(float i = 0.; i < ite; i++) {
		float ang = top / base * TAU;
		top += 2.;
		if(top >= base) {
			top = 1.;
			base *= 2.;
		}
		
		shf.x = cos(ang);
		shf.y = sin(ang);
		
		for(float j = 0.; j < dimension.x; j++) {
			vec2 _pos = v_vTexcoord + shf * j * tx;
			
			if(_pos.x < 0. || _pos.y < 0. || _pos.x > 1. || _pos.y > 1.)
				break;
			
			vec4 c = texture2D( gm_BaseTexture, _pos );
			if(c == red) {
				gl_FragColor = red;
				return;
			}
		
			if(c.rgb == vec3(0.))
				break;
		}
	}
}
