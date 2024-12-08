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

uniform int       useSurf;
uniform sampler2D prevFrame;

uniform vec2  dimension;
uniform int   axis;
uniform int   invert;
uniform float size;

void main() {
    vec2 px  = v_vTexcoord * dimension - .5;
         px /= size;
    vec2 md = mod(px, 2.);
    if(invert == 1)
        md = 1. - md;
        
    gl_FragColor = vec4(0.);
    if((axis == 0 && md.y < 1.) || (axis == 1 && md.x < 1.))
        gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
    else if(useSurf == 1)
        gl_FragColor = texture2D( prevFrame, v_vTexcoord );
}

