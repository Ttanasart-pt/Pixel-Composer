varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

uniform float direction;
uniform float sweep;
uniform float radius;

uniform int shade;
uniform int transparent;

#define PI 3.14159265358979323846

void main() {
	vec2  tx = 1. / dimension;
	float a0 = direction - sweep;
	float a1 = direction + sweep;
	
	vec4 base = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = vec4(0.);
	
	if((base.r + base.g + base.b) / 3. * base.a < .5) return;
	
	float dirr = 0.;
	
	for(float i = 1.; i <= radius; i++)
	for(float j = a0; j <= a1; j++) {
		float a   = radians(j);
		vec2 offs = vec2(cos(a), -sin(a)) * i * tx;
		vec2 sx   = v_vTexcoord + offs;
		
		vec4 sm = texture2D(gm_BaseTexture, sx);
		if((sm.r + sm.g + sm.b) / 3. * sm.a < .5) {
			dirr = 1. - i / radius;
			i    = radius + 1.;
			break;
		}
	}
	
	if(shade == 0) dirr = dirr > 0.? 1. : 0.;
	
	float aa = 1.;
	if(transparent == 1 && dirr == 0.) aa = 0.; 
	
	gl_FragColor = vec4(dirr,dirr,dirr,aa);
	
}