//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform float rad;

#define TAU   6.28318

void main() {
	vec2 pixelPosition = v_vTexcoord * dimension;
	float tau_div = TAU / 64.;
	
	gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
	if(length(gl_FragColor.rgb) * gl_FragColor.a <= 0.) {
		gl_FragColor.a = 1.;
		return;
	}
	
	float maxCorner = 0.;
	float minDistance = rad;
	
	for(float i = rad; i >= 1.; i--)
	for(float j = 0.; j < 80.; j++) {
		float ang = j * tau_div;
		vec2 pxs = (pixelPosition + vec2( cos(ang) * i,  sin(ang) * i)) / dimension;
		
		if(pxs.x < 0. || pxs.x > 1. || pxs.y < 0. || pxs.y > 1.)
			continue;
		
		float corn = floor(texture2D( gm_BaseTexture, pxs).r * rad);
		
		if(corn >= maxCorner) {
			maxCorner = corn;
			minDistance = i;
		}
	}
	
	if(minDistance < maxCorner)
		gl_FragColor = vec4(vec3(1.), 1.);
	else 
		gl_FragColor = vec4(vec3(0.), 1.);
}
