//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;

#define TAU 6.283185307179586
#define angle_sample 4.
#define distance_sample 64.

void main() {
	vec2 pixelPosition = v_vTexcoord * dimension;
	vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
	vec2 scale = dimension / distance_sample;
	float min_dist = 1.;
    gl_FragColor = col;
	
	if(col.a == 1.) 
		return;
	
	float tauDiv = TAU / angle_sample;
	for(float i = 1.; i <= distance_sample; i++)
	for(float j = 0.; j < angle_sample; j++) {
		float ang = j * tauDiv;
		vec2  pxs = (pixelPosition + vec2( cos(ang),  sin(ang)) * scale * i) / dimension;
		vec4  sam = texture2D( gm_BaseTexture, pxs );
				
		if(sam.a < 1.) continue;
			
		gl_FragColor = sam;
		return;
	}
}
