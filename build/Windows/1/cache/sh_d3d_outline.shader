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

uniform vec2 dimension;
uniform vec4 outlineColor;

#define TAU 6.283185307179586

void main() {
	vec2 pixelPosition = v_vTexcoord * dimension;
	gl_FragColor = vec4(0.);
	
	vec4 sam = texture2D( gm_BaseTexture, v_vTexcoord );
	if(sam.r > 0.) return;
	
	for(float i = 1.; i <= 2.; i++) {
		float base = 1.;
		float top  = 0.;
		for(float j = 0.; j <= 8.; j++) {
			float ang = top / base * TAU;
			top += 2.;
			if(top >= base) {
				top = 1.;
				base *= 2.;
			}
			
			vec2 pxs = (pixelPosition + vec2( cos(ang),  sin(ang)) * i) / dimension;
			vec4 sam = texture2D( gm_BaseTexture, pxs );
			
			if(sam.r > 0.) {
				gl_FragColor = outlineColor;
				return;
			}
		}
	}
}

