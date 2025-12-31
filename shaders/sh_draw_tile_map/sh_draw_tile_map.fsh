varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 tileSize;

uniform sampler2D tileTexture;
uniform vec2 tileTextureDim;

uniform sampler2D indexTexture;
uniform vec2 indexTextureDim;

uniform int animatedTiles[1024];
uniform int animatedTilesIndex[128];
uniform int animatedTilesLength[128];
uniform float frame;

int imod(int a, int b) { return a - (a/b) * b; }

void main() {
    gl_FragColor = vec4(0.);
    
    vec2 px    = v_vTexcoord * dimension;
    int  index = 0;
    
    ivec2 tileAmo = ivec2(tileTextureDim / tileSize);
    vec4  samIdx  = texture2D( indexTexture, floor(px / tileSize) / (indexTextureDim - 1.) );
    int   tileid  = int(samIdx.r + .1 * sign(samIdx.r));
    
    if(tileid == 0) 
        return;
    
    if(tileid > 0) {
        index  = tileid - 1;
        
    } else if(tileid < 0) { // animated tiles
        int aId     = -tileid - 1;
        int aIndex  = animatedTilesIndex[aId];
        int aLength = animatedTilesLength[aId];
        int animL   = imod(int(frame), aLength);
        index = animatedTiles[aIndex + animL];
    }
    
    int tx = imod(index, tileAmo.x);
    int ty = index / tileAmo.x;
    
    vec2 texTx  = vec2(tx, ty) * tileSize;
    vec2 tileTx = mod(px, tileSize) / tileSize;
    
    int vari   = int(samIdx.g + .1);
    int mRot   = imod(vari,   4);
    int mFlipH = imod(vari/4, 2);
    int mFlipV = imod(vari/8, 2);
    
    if(mFlipH == 1) tileTx.x = 1. - tileTx.x;
    if(mFlipV == 1) tileTx.y = 1. - tileTx.y;
    
    if(mRot   == 1) tileTx = vec2(tileTx.y, 1. - tileTx.x);
    if(mRot   == 2) tileTx = 1. - tileTx;
    if(mRot   == 3) tileTx = vec2(1. - tileTx.y, tileTx.x);
    
    vec2  samTx = texTx + tileTx * tileSize;
    gl_FragColor = texture2D( tileTexture, samTx / tileTextureDim );
}
