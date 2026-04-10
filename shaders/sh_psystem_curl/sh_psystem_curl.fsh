varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int  oversample;

vec2 sampleVec(vec2 pos) {
	     if(oversample == 0) pos = fract(fract(pos) + 1.);
	else if(oversample == 1) pos = clamp(pos, 0., 1.);
	
	vec4 sam = texture2D(gm_BaseTexture, pos);
	return sam.xy;
}

void main() {
	vec2 tx = 1. / dimension;
	
	// Compute partial derivatives for curl calculation
	// ∂u/∂y - derivative of x-component (red channel) with respect to y
	float dudy = sampleVec(v_vTexcoord + vec2(0., tx.y)).x - sampleVec(v_vTexcoord - vec2(0., tx.y)).x;
	// ∂v/∂x - derivative of y-component (green channel) with respect to x  
	float dvdx = sampleVec(v_vTexcoord + vec2(tx.x, 0.)).y - sampleVec(v_vTexcoord - vec2(tx.x, 0.)).y;
	
	// Curl = ∂v/∂x - ∂u/∂y
	float curl = dvdx - dudy;
	
	gl_FragColor = vec4(curl, curl, curl, 1.);
}