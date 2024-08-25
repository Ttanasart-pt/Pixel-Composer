varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 tiling;

void main() {
    vec2 px = fract(v_vTexcoord * tiling);
    gl_FragColor = texture2D( gm_BaseTexture, px );
}
