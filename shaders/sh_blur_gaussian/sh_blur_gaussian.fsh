//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int  horizontal;

uniform float weight[32];
uniform int	  size;
uniform int	  sampleMode;

uniform int  overrideColor;
uniform vec4 overColor;

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

float wgh = 0.;

vec4 sample(in vec2 pos, in int index) {
	vec4 col = sampleTexture( pos );
	col.rgb *= weight[index] * col.a;
	wgh     += weight[index] * col.a;
	return col;
}

void main() {
    vec2  tex_offset = 1.0 / dimension, pos;
    vec4  result = sample( v_vTexcoord, 0 );
	
    if(horizontal == 1) {
        for(int i = 1; i < size; i++) {
			pos = vec2(tex_offset.x * float(i), 0.0);
			
			result += sample( v_vTexcoord + pos, i );
			result += sample( v_vTexcoord - pos, i );
        }
    } else {
        for(int i = 1; i < size; i++) {
			pos = vec2(0.0, tex_offset.y * float(i));
			
			result += sample( v_vTexcoord + pos, i );
			result += sample( v_vTexcoord - pos, i );
        }
    }
	
	result.rgb /=  wgh;
	result.a    =  wgh;
	
	gl_FragColor = result;
	if(overrideColor == 1) 
		gl_FragColor.rgb = overColor.rgb;
}

