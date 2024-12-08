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

const float PI  = 3.14159265;
const float ATR = PI / 180.;

uniform int   convStepNums;
uniform float itrStepPixLen;
uniform float distanceAttenuation;
uniform float vectorCirculationRate;

uniform vec2  dimension;
uniform float seed;

vec4  getCol(vec2 pos) { return texture2D( gm_BaseTexture, pos / dimension); }
float getD(vec2 pos)   { return length(texture2D( gm_BaseTexture, pos / dimension)); }

vec2 grad( vec2 pos, float delta) {
    vec2  e = vec2(1., 0.) * delta;
    float o = getD(pos);
    
    return vec2(getD(pos + e.xy) - o,
                getD(pos + e.yx) - o) / delta;
}

void main() {
    vec2  pos = v_vTexcoord * dimension;
    float r   = 1.;
    float acc = 0.;
    vec4  res = vec4(0.);
    
    for(int i = 0; i < convStepNums; i++) {
        res += getCol(pos) * r;
        
        vec2 dir = grad(pos, itrStepPixLen) + vec2(1) * 0.001;
        
        pos += 2. * normalize(mix(dir, dir.yx * vec2(1, -1), vectorCirculationRate));
        acc += r;
        r   *= distanceAttenuation;
    }
    
    res.xyz /= acc;
    
    gl_FragColor = res;
}

