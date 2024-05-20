varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D map;

void main() {
    vec4 cord = texture2D( map, v_vTexcoord );
    gl_FragColor = texture2D( gm_BaseTexture, cord.xy );
}
