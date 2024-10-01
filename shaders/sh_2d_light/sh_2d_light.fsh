varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4  color;
uniform float intensity;
uniform float band;

uniform int   atten;
uniform float exponent;

void main() {
	vec4  samp   = texture2D( gm_BaseTexture, v_vTexcoord);
	float bright = (samp.r + samp.b + samp.g) / 3.;
	
		 if(atten == 0) bright = pow(bright, exponent);
	else if(atten == 1) bright = 1. - pow(1. - bright, exponent);
	else if(atten == 2) bright = bright;
	bright *= intensity;
		
	if(band > 0.) bright = ceil(bright * band) / band;
	
    gl_FragColor = vec4(color.rgb * bright, 1.);
}
