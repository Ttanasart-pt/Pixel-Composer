varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D group;
uniform vec2  dimension;
uniform float seed;

uniform float probability;

uniform vec2  size;
uniform int   range;
uniform float selection[64];

uniform float replacements[1024];
uniform int   replacementCount;

vec2 tx   = 1. / dimension;

float random (in vec2 st, float seed) { return fract(sin(dot(st.xy + seed / 1000., vec2(1892.9898, 78.23453))) * 437.54123); }

bool match(in vec2 p) {
    int _w = int(size.x) + range * 2;
    int _h = int(size.y) + range * 2;
    
    for(int i = 0; i < _h; i++)
    for(int j = 0; j < _w; j++) {
        float selInd = selection[i * _w + j];
        int _x = j - range;
        int _y = i - range;
        
        if(selInd == -1.) continue; // skip matching
        if(selInd == -10000.) selInd = -1.; // match empty
        
        vec2 sx = p + vec2(_x, _y) * tx;
        
        if(selInd >= 10000.) {
            vec4 gr = texture2D( group, sx );
            if(gr.r != selInd) return false;
            
        } else {
            vec4 sp = texture2D( gm_BaseTexture, sx );
            if(sp.r - 1. != selInd) return false;
        }
    }
    
    return true;
}

void main() {
    vec4 base = texture2D( gm_BaseTexture, v_vTexcoord );
    gl_FragColor = base;
    
    vec2 origin = v_vTexcoord;
    int  repShf = -1;
    
    for(int i = 0; i < int(size.y); i++)
    for(int j = 0; j < int(size.x); j++) {
        vec2 o = v_vTexcoord - vec2(j, i) * tx;
        if(match(o)) {
            origin = o;
            repShf = i * int(size.x) + j;
            break;
        }
    }
    
    if(repShf == -1) return;
    
    float prop = random(origin, seed);
    if(prop > probability) return;
    
    int repIndex = int(random(origin, seed + 100.) * float(replacementCount)) * int(size.x * size.y);
    gl_FragColor = vec4(replacements[repIndex + repShf] + 1., 0., 0., 1.);
}
