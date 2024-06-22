varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int  horizontal;

uniform float weight[128];
uniform int	  size;
uniform float angle;
uniform int	  sampleMode;

uniform int  overrideColor;
uniform vec4 overColor;

uniform int  gamma;

vec4 sampleTexture(vec2 pos) {
	if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
		return texture2D(gm_BaseTexture, pos);
	
	if(sampleMode == 0) 
		return vec4(0.);
		
	else if(sampleMode == 1) 
		return texture2D(gm_BaseTexture, clamp(pos, 0., 1.));
		
	else if(sampleMode == 2) 
		return texture2D(gm_BaseTexture, fract(pos));
	
	else if(sampleMode == 3) 
		return vec4(vec3(0.), 1.);
	
	return vec4(0.);
}

float wgh = 0.;

vec4 sample(in vec2 pos, in int index) {
	vec4 col = sampleTexture( pos );
	if(gamma == 1) col.rgb = pow(col.rgb, vec3(2.2));
	
	col.rgb *= weight[index] * col.a;
	wgh     += weight[index] * col.a;
	
	return col;
}

void main() {
    vec2 tex_offset = 1.0 / dimension, pos;
    vec4 result     = sample( v_vTexcoord, 0 );
    mat2 rot        = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
	
    if(horizontal == 1) {
        for(int i = 1; i < size; i++) {
			pos = rot * vec2(tex_offset.x * float(i), 0.0);
			
			result += sample( v_vTexcoord + pos, i );
			result += sample( v_vTexcoord - pos, i );
        }
    } else {
        for(int i = 1; i < size; i++) {
			pos = rot * vec2(0.0, tex_offset.y * float(i));
			
			result += sample( v_vTexcoord + pos, i );
			result += sample( v_vTexcoord - pos, i );
        }
    }
	
	result.rgb /=  wgh;
	result.a    =  wgh;
	
	if(gamma == 1) result.rgb = pow(result.rgb, vec3(1. / 2.2));
	
	gl_FragColor = result;
	if(overrideColor == 1) {
		gl_FragColor.rgb = overColor.rgb;
		gl_FragColor.a  *= overColor.a;
	}
}

