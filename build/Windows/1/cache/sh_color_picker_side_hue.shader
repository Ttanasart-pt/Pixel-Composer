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
//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#ifdef _YY_HLSL11_ 
	#define PALETTE_LIMIT 1024 
#else 
	#define PALETTE_LIMIT 256 
#endif

uniform float sat;
uniform float value;

uniform int usePalette;
uniform vec4 palette[PALETTE_LIMIT];
uniform int paletteAmount;

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
	vec3 _rgb;
	
		 if(usePalette == 0) _rgb = hsv2rgb(vec3(v_vTexcoord.y, 1., 1.)); 
	else if(usePalette == 1) _rgb = hsv2rgb(vec3(v_vTexcoord.y, sat, value)); 
		
	vec4 color = vec4(_rgb.r, _rgb.g, _rgb.b, v_vColour.a);
	
	if(usePalette == 1) {
		int index = 0;
		float minDist = 999.;
		for(int i = 0; i < paletteAmount; i++) {
			float dist = distance(color.rgb, palette[i].rgb);
			
			if(dist < minDist) {
				minDist = dist;
				index = i;
			}
		}
		
		color = palette[index];
	}
	
    gl_FragColor = color;
}

