varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 tileSize;
uniform vec2 tileAmo;

uniform sampler2D tileTexture;
uniform vec2 tileTextureDim;

uniform sampler2D indexTexture;
uniform vec2 indexTextureDim;

void main() {
    vec2  px = v_vTexcoord * dimension;
    vec2  tileTx = mod(px, tileSize);
    
    float index = texture2D( indexTexture, floor(px / tileSize) / indexTextureDim ).r - 1.;
    vec2  texTx = vec2(mod(index, tileAmo.x), floor(index / tileAmo.x)) * tileSize;
    
    gl_FragColor = texture2D( tileTexture, (texTx + tileTx) / tileTextureDim );
    // gl_FragColor = vec4(tileTx, 0., 1.);
}
