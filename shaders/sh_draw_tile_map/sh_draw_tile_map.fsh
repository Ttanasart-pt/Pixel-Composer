varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 tileSize;

uniform sampler2D tileTexture;
uniform vec2 tileTextureDim;

uniform sampler2D indexTexture;
uniform vec2 indexTextureDim;

uniform float animatedTiles[1024];
uniform float animatedTilesIndex[128];
uniform float animatedTilesLength[128];
uniform float frame;

int mod(int a, int b) { return a - (a / b) * b; }

void main() {
    gl_FragColor = vec4(0.);
    
    vec2  px = v_vTexcoord * dimension;
    vec2  tileTx, texTx;
    float index = 0.;
    
    vec2 tileAmo  = floor(tileTextureDim / tileSize);
    vec4 samIdx   = texture2D( indexTexture, floor(px / tileSize) / (indexTextureDim - 1.) );
    if(samIdx.r == 0.) return;
    
    if(samIdx.r > 0.) {
        index  = samIdx.r - 1.;
        
    } if(samIdx.r < 0.) { // animated tiles
        int aId = int(-samIdx.r - 1.);
        float aIndex  = animatedTilesIndex[aId];
        float aLength = animatedTilesLength[aId];
        float animL   = mod(frame, float(aLength));
        index = animatedTiles[int(aIndex + animL)];
    }
    
    texTx  = vec2(mod(index, tileAmo.x), floor(index / tileAmo.x)) * tileSize;
    tileTx = mod(px, tileSize) / tileSize;
    
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
