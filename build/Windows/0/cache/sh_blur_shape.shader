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

uniform vec2 dimension;

uniform sampler2D blurMask;
uniform vec2 blurMaskDimension;

uniform int useMask;
uniform sampler2D mask;

uniform int mode;
uniform int gamma;

float sampleMask() { 
	if(useMask == 0) return 1.;
	vec4 m = texture2D( mask, v_vTexcoord );
	return (m.r + m.g + m.b) / 3. * m.a;
} 

float sampleBlurMask(vec2 pos) { 
	vec4 m = texture2D( blurMask, 1. - pos );
	return (m.r + m.g + m.b) / 3. * m.a;
} 

void main() {
	gl_FragColor = sampleTexture( gm_BaseTexture, v_vTexcoord );
	
	vec2 px   = v_vTexcoord * dimension;
	vec2 tx   = 1. / dimension;
	float msk = sampleMask();
	if(msk == 0.) return;
	
	float bs  = 1. / msk;
	
	vec4  col    = vec4(0.);
	float weight = 0.;
	
	vec2 bdim2 = blurMaskDimension / 2.;
	
	for(float i = 0.; i <= 64.; i++)
	for(float j = 0.; j <= 64.; j++) {
		if(i >= blurMaskDimension.x || j >= blurMaskDimension.y) continue;
		
		vec2 bPx = (vec2(i, j) - bdim2) * bs;
		if(abs(bPx.x / blurMaskDimension.x) >= .5 || abs(bPx.y / blurMaskDimension.y) >= .5) continue;
		
		vec4  c = sampleTexture( gm_BaseTexture, (px + bPx) * tx);
		float b = sampleBlurMask(bPx / blurMaskDimension + 0.5);
		
		if(gamma == 1) c.rgb = pow(c.rgb, vec3(2.2));
		
		if(mode == 0) {
			col    += c * b;
			weight += b;
		} else if(mode == 1) {
			col     = max(col, c * b);
		}
	}
	
	     if(mode == 0) col /= weight;
	else if(mode == 1) col.a = 1.;
	
	if(gamma == 1) col.rgb = pow(col.rgb, vec3(1. / 2.2));
	
	gl_FragColor = col;
}

