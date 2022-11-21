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
	float bright = dot(v_vColour.rgb, vec3(0.2126, 0.7152, 0.0722));
	bright = min(max(bright, 0.), 1.);
	
	if(atten == 0.)
		bright = bright * bright;
	else if(atten == 1.)
		bright = 1. - (bright - 1.) * (bright - 1.);
	else if(atten == 2.)
		bright = bright;
	
	bright *= intensity;
		
	if(band > 0.)
		bright = ceil(bright * band) / band;
	
	vec4 col = vec4(color, bright);
    gl_FragColor = col;
}
