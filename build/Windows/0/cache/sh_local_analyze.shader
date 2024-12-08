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
uniform int   algorithm;
uniform int   shape;
uniform float size;

float bright(in vec4 col) { return dot(col.rgb, vec3(0.2126, 0.7152, 0.0722)) * col.a; }

void main() { 
	vec2 tex     = 1. / dimension;
	vec4 acc     = vec4(0.);
	vec4 maxx    = vec4(0.), minn = vec4(1.);
	float weight = 0., _w;
	vec4 col     = sampleTexture( gm_BaseTexture, v_vTexcoord );
	
	for(float i = -size; i <= size; i++)
	for(float j = -size; j <= size; j++) {
		if(shape == 1 && i * i + j * j > size * size) 
			continue;
		if(shape == 2 && abs(i) + abs(j) > size) 
			continue;
		
		if(shape == 0)
			_w = min(size - abs(i), size - abs(j));
		else if(shape == 1)
			_w = size - length(vec2(i, j));
		else if(shape == 2)
			_w = size - (abs(i) + abs(j));
		
		vec4 col = sampleTexture( gm_BaseTexture, v_vTexcoord + vec2(i, j) * tex );
		
		if(algorithm == 0) {
			acc += col;	
			weight++;
		} else if(algorithm == 1) {
			maxx = max(maxx, col);
		} else if(algorithm == 2) {
			minn = min(minn, col);
		}
	}
	
	if(algorithm == 0)
		gl_FragColor = acc / weight;
	else if(algorithm == 1)
		gl_FragColor = maxx;
	else if(algorithm == 2)
		gl_FragColor = minn;
}

