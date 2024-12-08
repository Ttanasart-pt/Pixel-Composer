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

uniform vec2 dimension;
uniform int  edge;
uniform vec4 edgeColor;

vec2 tx;

float samp(float x, float y) {
    vec4 a = texture2D( gm_BaseTexture, v_vTexcoord + vec2(x, y) * tx );
    return a.a;
}

void main() {
    tx = 1. / dimension;
    
    float a0 = samp(-1., -1.);
    float a1 = samp( 0., -2.);
    float a2 = samp( 1., -1.);
    
    float a3 = samp(-2.,  0.);
    float a4 = samp( 0.,  0.);
    float a5 = samp( 2.,  0.);
    
    float a6 = samp(-1.,  1.);
    float a7 = samp( 0.,  2.);
    float a8 = samp( 1.,  1.);
    
    gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
    
    if(a4 == 0.) return;
    
    if(a0 < 1. || a1 < 1. || a2 < 1. || a3 < 1. || a5 < 1. || a6 < 1. || a7 < 1. || a8 < 1.) {
        gl_FragColor.rgb = edge == 1? edgeColor.rgb : vec3(1.);
        
        float b0 = samp(-1.,  0.);
        float b1 = samp( 1.,  0.);
        float b2 = samp( 0., -1.);
        float b3 = samp( 0.,  1.);
        
        if(b0 < 1. || b1 < 1. || b2 < 1. || b3 < 1.)
            gl_FragColor.rgb = vec3(0.);
    }
}

