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

uniform float size;
uniform int scale;

uniform vec2      direction;
uniform int       directionUseSurf;
uniform sampler2D directionSurf;

uniform vec2      strength;
uniform int       strengthUseSurf;
uniform sampler2D strengthSurf;

uniform int	  gamma;

vec4 dirBlur(vec2 angle) { 
    vec4 acc     = vec4(0.);
    float delta  = 1. / size;
	float weight = 0.;
    
	if(scale == 0) {
	    for(float i = -1.0; i <= 1.0; i += delta) {
			vec4 col  = sampleTexture( gm_BaseTexture, v_vTexcoord - angle * i);
			if(gamma == 1) col.rgb = pow(col.rgb, vec3(2.2));
			
	        acc      += col;
			weight   += col.a;
	    }
		
		acc.rgb /= weight;
		acc.a   /= size * 2.;
	} else {
		for(float i = 0.; i <= 1.0; i += delta) {
			vec4 col  = sampleTexture( gm_BaseTexture, v_vTexcoord - angle * i);
			if(gamma == 1) col.rgb = pow(col.rgb, vec3(2.2));
			
	        acc      += col  ;
			weight   += col.a;
	    }
		
		acc.rgb /= weight;
		acc.a   /= size - 1.;
		
		acc += sampleTexture( gm_BaseTexture, v_vTexcoord );
	}
	
	if(gamma == 1) acc.rgb = pow(acc.rgb, vec3(1. / 2.2));
    return acc;
} 

void main() {
	float str = strength.x;
	if(strengthUseSurf == 1) {
		vec4 _vMap = texture2D( strengthSurf, v_vTexcoord );
		str = mix(strength.x, strength.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float dir = direction.x;
	if(directionUseSurf == 1) {
		vec4 _vMap = texture2D( directionSurf, v_vTexcoord );
		dir = mix(direction.x, direction.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
    float r = radians(dir + 90.);
    vec2 dirr = vec2(sin(r), cos(r)) * str;
    
    gl_FragColor = dirBlur(dirr);
}

