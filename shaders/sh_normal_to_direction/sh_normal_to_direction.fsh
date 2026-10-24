varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float smooth;

uniform float direction;
uniform float scale;
uniform int   inverted;

#define PI 3.14159265358979323846

void main() {
	vec2 tx = 1. / dimension;
	vec4 normal  = texture2D(gm_BaseTexture, v_vTexcoord) * v_vColour;
	vec3 norm    = vec3(0.);
	
	if(smooth > 0.) {
		float weight = 0.;
		for(float x = -smooth; x <= smooth; x++)
		for(float y = -smooth; y <= smooth; y++) {
			vec2 sx = v_vTexcoord + vec2(x, y) * tx;
			vec4 _normal = texture2D(gm_BaseTexture, sx);
			if(_normal.a <= 0.) continue;
			
			vec3 _norm = _normal.rgb - .5;
			
			norm += _norm;
			weight++;
		}
		
		norm /= weight;
	} else
		norm = normal.rgb - .5;
	
	float dir   = atan(norm.y, norm.x);
	      dir   = dir / PI / 2. * scale;
	      dir   = fract(fract(dir) + 1.);
	      
	if(inverted == 1) dir = 1. - dir;
	
	dir += radians(direction) / PI;
	dir  = fract(fract(dir) + 1.);
	
	gl_FragColor = vec4(dir, dir, dir, normal.a);
}