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
uniform float radius;
uniform float intensity;

void main() {
    vec2  tx = 1. / dimension;
    vec4  ss = vec4(0.);
    float ww = 0.;
    
    for(float i = -radius; i <= radius; i++)
    for(float j = -radius; j <= radius; j++) {
        if(i == 0. && j == 0.) continue;
        
        vec2 sx = v_vTexcoord + vec2(i, j) * tx;
        float w = (radius - (abs(i) + abs(j)) + 1.) / radius / 4.;
        if(w <= 0.) continue;
        
        ss -= sampleTexture( gm_BaseTexture, sx ) * w;
        ww += w;
    }
    
    vec4 sc = sampleTexture( gm_BaseTexture, v_vTexcoord );
    ss += sc * ww;
    
    gl_FragColor = vec4(ss.rgb * intensity, sc.a);
}

