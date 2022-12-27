//
// Simple passthrough fragment shader
//
//varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec3 color;
uniform float intensity;
uniform float band;
uniform float atten;

void main() {
	float bright = (v_vColour.r + v_vColour.b + v_vColour.g) / 3.;
	bright = clamp(bright, 0., 1.);
	
	if(atten == 0.)
		bright = bright * bright;
	else if(atten == 1.)
		bright = 1. - (bright - 1.) * (bright - 1.);
	else if(atten == 2.)
		bright = bright;
	
	bright *= intensity;
		
	if(band > 0.)
		bright = ceil(bright * band) / band;
	
    gl_FragColor = vec4(color, 1.) * bright;
}
