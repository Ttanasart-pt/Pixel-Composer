//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform float size;
uniform int border;
uniform int alpha;

#define TAU 6.283185307179586

float bright(in vec4 col) {
	return dot(col.rgb, vec3(0.2126, 0.7152, 0.0722)) * col.a;
}

void main() {
	vec2 pixelPosition = v_vTexcoord * dimension;
	vec4 point = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 fill = vec4(0.);
	if(alpha == 0) fill.a = 1.;
	gl_FragColor = point;
	
	if(alpha == 0 && length(point.rgb) <= 0.) 
		return;
	if(alpha == 1 && point.a <= 0.)
		return;
		
	for(float i = 1.; i < size; i++) {
		float base = 1.;
		float top  = 0.;
		for(float j = 0.; j <= 64.; j++) {
			float ang = top / base * TAU;
			top += 2.;
			if(top >= base) {
				top = 1.;
				base *= 2.;
			}
			
			vec2 pxs = (pixelPosition + vec2( cos(ang) * i,  sin(ang) * i)) / dimension;
			if(border == 1)
				pxs = clamp(pxs, vec2(0.), vec2(1.));
		
			if(pxs.x < 0. || pxs.x > 1. || pxs.y < 0. || pxs.y > 1.) {
				gl_FragColor = fill;
				break;
			}
			
			vec4 sam = texture2D( gm_BaseTexture, pxs );
			if((alpha == 0 && length(sam.rgb) * sam.a == 0.) || (alpha == 1 && sam.a == 0.)) {
				gl_FragColor = fill;
				break;
			}
		}
	}
}
