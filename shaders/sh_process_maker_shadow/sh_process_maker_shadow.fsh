varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define TAU 6.283185307179586

uniform vec2  dimension;
uniform int   process;
uniform vec4  color;
uniform float shadow;
uniform float intensity;

void main() {
	vec2 tx = 1. / dimension;
	
	vec4 samp = texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = vec4(0.);
	
	if(samp.a > 0.) {
		gl_FragColor = color;
		return;
	}
	
	float ang;
	for(float i = -shadow; i <= shadow; i++) {
		vec2 pxs = v_vTexcoord;
		if(process == 0)
			 pxs.x += i * tx;
		else pxs.y += i * tx;
		
		vec4 ccc = texture2D(gm_BaseTexture, pxs);
		
		if(ccc.a > 0.) {
			float dist = 1. - i / shadow;
			      dist = dist * dist * dist;
			gl_FragColor = vec4(color.rgb, dist * intensity) * v_vColour;
			return;
		}
	}
			
}