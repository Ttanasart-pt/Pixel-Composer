varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4  target;
uniform float replace;

void main() {
    vec4 base = texture2D( gm_BaseTexture, v_vTexcoord );
    gl_FragColor = base;
    if(base.a == 2.) return;
    
    if(distance(base.rgb, target.rgb) < .01)
        gl_FragColor = vec4(replace, 0., 0., 2.);
}
