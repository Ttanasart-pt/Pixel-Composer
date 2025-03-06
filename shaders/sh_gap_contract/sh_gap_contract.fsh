varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 direction;

float light(vec4 cc) { return (cc.r + cc.g + cc.b) / 3. * cc.a; } 

void main() {
	vec2 tx = 1. / dimension;
	vec4 cc = texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = cc;
	if(light(cc) > 0.) return;
	
	vec4 c0 = texture2D(gm_BaseTexture, v_vTexcoord + direction * tx);
	vec4 c1 = texture2D(gm_BaseTexture, v_vTexcoord - direction * tx);
	vec4 c2 = texture2D(gm_BaseTexture, v_vTexcoord - (direction + direction.yx) * tx);
	vec4 c3 = texture2D(gm_BaseTexture, v_vTexcoord - (direction - direction.yx) * tx);
	
	if(light(c0) > 0. && light(c1) == 0. && light(c2) == 0. && light(c3) == 0.) 
		gl_FragColor = vec4(1., 1., 1., 1.);
	
	
}