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

uniform vec2  dimension;
uniform vec2  position;
uniform vec2  scale;
uniform float seed;

uniform int useSampler;

float random (in vec2 st, float seed) {
    return fract(sin(dot(st.xy + seed, vec2(1892.9898, 78.23453))) * 437.54123);
}

vec2 triChecker(vec2 p) {
    p.x += fract(p.y * .5);
    vec2 m = fract(p); 
    vec2 base = p - m;
    
    base.x *= 2. + step(m.x, m.y);
    
    return base;
}

void main() {
	vec2 pos = (v_vTexcoord - position / dimension) * scale;
	pos.y *= 1.1;
	vec2 hx = triChecker(pos);
	
	if(useSampler == 0) {
		float n0 = random(hx, floor(seed) / 5000.);
		float n1 = random(hx, (floor(seed) + 1.) / 5000.);
		float n  = mix(n0, n1, fract(seed));
		gl_FragColor = vec4(vec3(n), 1.0);
	} else {
		vec2 samPos = floor(hx) / scale + 0.5 / scale;
		gl_FragColor = sampleTexture( gm_BaseTexture, samPos / vec2(sqrt(3.), 1.1));
	}
}

