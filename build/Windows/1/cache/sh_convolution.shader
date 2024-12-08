//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
#pragma use(sampler_simple)


    uniform int  sampleMode;
    
    vec4 sampleTexture( sampler2D texture, vec2 pos) {
        if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
            return texture2D(texture, pos);
        
             if(sampleMode <= 1) return vec4(0.);
        else if(sampleMode == 2) return texture2D(texture, clamp(pos, 0., 1.));
        else if(sampleMode == 3) return texture2D(texture, fract(pos));
        else if(sampleMode == 4) return vec4(vec3(0.), 1.);
        
        return vec4(0.);
    }


varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int   size;
uniform vec2  dimension;
uniform float kernel[256];
uniform int   normalized;

void main() {
	vec2  tx  = 1. / dimension;
	float sum = 1.;
	
	if(normalized == 1) {
		sum = 0.;
		int amo = size * size;
		for(int i = 0; i < amo; i++) sum += kernel[i];
		
		if(sum == 0.) sum = 1.;
	}
	
	float st = -(float(size) - 1.) / 2.;
	vec4  c  = vec4(0.);
	
	for(int i = 0; i < size; i++)
	for(int j = 0; j < size; j++) {
		int  index = i * size + j;
		vec2 px    = v_vTexcoord + vec2((float(j) + st) * tx.x, (float(i) + st) * tx.y);
		
		float w = kernel[index];
		if(w == 0.) continue;
		
		c += w * sampleTexture( gm_BaseTexture, px) / sum;
	}
	
    gl_FragColor = c;
}

