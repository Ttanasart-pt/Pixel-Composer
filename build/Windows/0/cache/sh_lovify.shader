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
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define SRGB_TO_LINEAR(c) pow((c), vec3(2.2))
#define LINEAR_TO_SRGB(c) pow((c), vec3(1.0 / 2.2))
#define SRGB(r, g, b) SRGB_TO_LINEAR(vec3(r, g, b) / 255.0)

void main() {
	vec4 c = texture2D( gm_BaseTexture, v_vTexcoord );
	
	vec3 COLOR0 = SRGB(252., 3., 111.);
	vec3 COLOR1 = SRGB(190., 3., 252.);
	
	float t = length(v_vTexcoord) / sqrt(2.);
          t = smoothstep(0.0, 1.0, clamp(t, 0.0, 1.0));
	
    vec3 color = mix(COLOR0, COLOR1, t);
	     color = LINEAR_TO_SRGB(color);
	vec4 b = vec4(color, 1.);
	
	float lum  = dot(c.rgb, vec3(0.2126, 0.7152, 0.0722));
	vec4 blend = lum > 0.5? (1. - (1. - 2. * (b - 0.5)) * (1. - c)) : ((2. * b) * c);
	     blend = 0.5 + (blend * 1.75 - 0.5) * 0.66;
		 
    gl_FragColor = blend;
}

