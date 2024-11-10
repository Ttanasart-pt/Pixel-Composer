varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D base;
uniform sampler2D light;

void main() {
    vec4 b = texture2D( base,  v_vTexcoord );
    vec4 l = texture2D( light, v_vTexcoord );
    
    gl_FragColor = vec4(b.rgb + l.rgb, b.a);
}
