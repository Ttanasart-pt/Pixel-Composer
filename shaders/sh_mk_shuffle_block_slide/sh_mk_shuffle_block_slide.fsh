varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float seed;
uniform float amount;
uniform vec2  dimension;
uniform vec2  block;
uniform int   axis;

float random (in vec2 st, float seed) { return fract(sin(dot(st.xy, vec2(1892.9898, 78.23453))) * (seed + 437.54123)); }

void main() {
    vec2 newPos = v_vTexcoord;
    
    if(axis == 0) {
        float blockIndex = floor(v_vTexcoord.x * block.x);
        float shift = random(vec2(blockIndex, seed / 1000.), seed) * amount;
              shift = floor(shift * block.y) / block.y;
        
        newPos.y = fract(newPos.y + shift);
        
    } else if(axis == 1) {
        float blockIndex = floor(v_vTexcoord.y * block.y);
        float shift = random(vec2(seed / 1000., blockIndex), seed) * amount;
              shift = floor(shift * block.x) / block.x;
        
        newPos.x = fract(newPos.x + shift);
    }
        
    gl_FragColor = texture2D( gm_BaseTexture, newPos );
}
