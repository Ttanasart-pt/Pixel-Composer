//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform float kernel[9];
uniform int sampleMode;

vec4 sampleTexture(vec2 pos) {
	if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
		return texture2D(gm_BaseTexture, pos);
	
	if(sampleMode == 0) 
		return vec4(0.);
	if(sampleMode == 1) 
		return texture2D(gm_BaseTexture, clamp(pos, 0., 1.));
	if(sampleMode == 2) 
		return texture2D(gm_BaseTexture, fract(pos));
	
	return vec4(0.);
}

void main() {
	vec2 tex = 1. / dimension;
	vec4 c = + kernel[0] * sampleTexture( v_vTexcoord + vec2(-tex.x, -tex.y) )
		     + kernel[1] * sampleTexture( v_vTexcoord + vec2(    0., -tex.y) )
		     + kernel[2] * sampleTexture( v_vTexcoord + vec2( tex.x, -tex.y) )
			
		     + kernel[3] * sampleTexture( v_vTexcoord + vec2(-tex.x, 0.) )
		     + kernel[4] * sampleTexture( v_vTexcoord + vec2(    0., 0.) )
		     + kernel[5] * sampleTexture( v_vTexcoord + vec2( tex.x, 0.) )
			
			 + kernel[6] * sampleTexture( v_vTexcoord + vec2(-tex.x, tex.y) )
		     + kernel[7] * sampleTexture( v_vTexcoord + vec2(    0., tex.y) )
		     + kernel[8] * sampleTexture( v_vTexcoord + vec2( tex.x, tex.y) );
	
    gl_FragColor = vec4(c.rgb, 1.);
}
