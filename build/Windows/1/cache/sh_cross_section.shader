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

uniform sampler2D histogram;

uniform vec2  dimension;
uniform int   iAxis, oAxis;
uniform float position;
uniform int   aa;
uniform int   mode;

void main() {
    vec2 tx = 1. / dimension;
    vec2 sm = iAxis == 0? vec2(v_vTexcoord.x, position) : vec2(position, v_vTexcoord.y);
    
    vec4  cc = texture2D( gm_BaseTexture, sm );
    float br = 1. - dot(cc.rgb, vec3(0.2126, 0.7152, 0.0722)) * cc.a;
    float bw = iAxis == 0? v_vTexcoord.y : 1. - v_vTexcoord.x;
    float fa = iAxis == 0? tx.x : tx.y;
    
    float res = aa == 0? step(br, bw) : smoothstep(br - fa, br + fa, bw);
    
    if(mode == 0) {
        gl_FragColor = vec4(vec3(res), 1.);
        
    } else if(mode == 1) {
        gl_FragColor = vec4(0.);
        if(res > 0.) gl_FragColor = vec4(cc.rgb, cc.a * res);
        
    }
}

