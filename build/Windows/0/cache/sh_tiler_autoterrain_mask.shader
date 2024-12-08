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

uniform sampler2D drawSurface;

uniform int indexes[1024];
uniform int indexSize;

void main() {
    int   ss = int(texture2D( gm_BaseTexture, v_vTexcoord )[0] - 1.);
    float dd = texture2D( drawSurface, v_vTexcoord )[0];
    
    vec4 res = vec4(0.);
    
    for(int i = 0; i < indexSize; i++) {
        if(indexes[i] == -1) continue;
        if(ss == indexes[i])
            res[0] = .5;
    }
    
    res[0] = max(res[0], dd);
    
    gl_FragColor = res;
}

