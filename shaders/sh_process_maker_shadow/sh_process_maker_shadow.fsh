varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define TAU 6.283185307179586

uniform vec2  dimension;
uniform vec4  color;
uniform float shadow;
uniform float intensity;

void main() {
	vec2 tx = 1. / dimension;
	
	gl_FragColor = texture2D(gm_BaseTexture, v_vTexcoord);
	if(gl_FragColor.a > 0.) return;
	
	float ang;
	
	for(float i = 1.; i <= shadow; i++) {
		float base = 1.;
		float top  = 0.;
		float atr  = 4. + i * 8.;
		
		for(float j = 0.; j <= atr; j++) {
			ang = top / base * TAU;
			top += 2.;
			if(top >= base) {
				top   = 1.;
				base *= 2.;
			}
			
			vec2 pxs = v_vTexcoord + vec2(cos(ang), sin(ang)) * i * tx;
			vec4 ccc = texture2D(gm_BaseTexture, pxs);
			
			if(ccc.a > 0.) {
				float dist = 1. - i / shadow;
				      dist = dist * dist * dist;
				gl_FragColor = vec4(color.rgb, dist * intensity);
				return;
			}
		}
	}
			
}