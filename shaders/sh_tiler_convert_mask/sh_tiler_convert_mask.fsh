varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4  target;
uniform float replace;

void main() {
    vec4 base = texture2D( gm_BaseTexture, v_vTexcoord );
    gl_FragColor = base == target? vec4(replace, 0., 0., 1.) : vec4(0.);
}
