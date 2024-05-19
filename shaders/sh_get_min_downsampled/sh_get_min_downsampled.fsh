varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform sampler2D surface;

void main() {
    vec2 tx = 1. / dimension;
    
    vec4 c = vec4(0.);
         c = min(c, texture2D( surface, v_vTexcoord + vec2(0., 0.) * tx ));
         c = min(c, texture2D( surface, v_vTexcoord + vec2(1., 0.) * tx ));
         c = min(c, texture2D( surface, v_vTexcoord + vec2(0., 1.) * tx ));
         c = min(c, texture2D( surface, v_vTexcoord + vec2(1., 1.) * tx ));
    
    gl_FragColor = c;
}
