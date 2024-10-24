varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 tileSize;
uniform vec2 tileAmo;

uniform sampler2D tileTexture;
uniform vec2 tileTextureDim;

uniform sampler2D indexTexture;
uniform vec2 indexTextureDim;

int mod(int a, int b) { return a - (a / b) * b; }

void main() {
    vec2  px = v_vTexcoord * dimension;
    
    vec4  samIdx = texture2D( indexTexture, floor(px / tileSize) / indexTextureDim );
    float index  = samIdx.r - 1.;
    vec2  texTx  = vec2(mod(index, tileAmo.x), floor(index / tileAmo.x)) * tileSize;
    vec2  tileTx = mod(px, tileSize) / tileSize;
    
    float vari  = samIdx.g + 0.1;
    
    float mRotation = mod(floor(vari),       4.);
    float mFlipH    = mod(floor(vari /  8.), 2.);
    float mFlipV    = mod(floor(vari / 16.), 2.);
    
    if(mFlipH    == 1.) tileTx.x = 1. - tileTx.x;
    if(mFlipV    == 1.) tileTx.y = 1. - tileTx.y;
    if(mRotation == 1.) tileTx = vec2(tileTx.y, 1. - tileTx.x);
    if(mRotation == 2.) tileTx = 1. - tileTx;
    if(mRotation == 3.) tileTx = vec2(1. - tileTx.y, tileTx.x);
    
    vec2  samTx = texTx + tileTx * tileSize;
    gl_FragColor = texture2D( tileTexture, samTx / tileTextureDim );
}
