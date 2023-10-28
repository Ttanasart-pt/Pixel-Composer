//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec4 outlineColor;

#define TAU 6.283185307179586

void main() {
	vec2 pixelPosition = v_vTexcoord * dimension;
	gl_FragColor = vec4(0.);
	
	vec4 sam = texture2D( gm_BaseTexture, v_vTexcoord );
	if(sam.r > 0.) return;
	
	for(float i = 1.; i <= 2.; i++) {
		float base = 1.;
		float top  = 0.;
		for(float j = 0.; j <= 8.; j++) {
			float ang = top / base * TAU;
			top += 2.;
			if(top >= base) {
				top = 1.;
				base *= 2.;
			}
			
			vec2 pxs = (pixelPosition + vec2( cos(ang),  sin(ang)) * i) / dimension;
			vec4 sam = texture2D( gm_BaseTexture, pxs );
			
			if(sam.r > 0.) {
				gl_FragColor = outlineColor;
				return;
			}
		}
	}
}
