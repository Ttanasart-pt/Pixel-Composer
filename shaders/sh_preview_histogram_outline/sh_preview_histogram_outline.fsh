varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

void main() {
    vec2 tx = 1. / dimension;
    
    gl_FragColor = vec4(0.);
    
    float a  = texture2D( gm_BaseTexture, v_vTexcoord ).a;
    if(a > 0.) return;
    
    a = texture2D( gm_BaseTexture, v_vTexcoord + vec2( tx.x, 0.) ).a; if(a > 0.) gl_FragColor = v_vColour;
    a = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tx.x, 0.) ).a; if(a > 0.) gl_FragColor = v_vColour;
    a = texture2D( gm_BaseTexture, v_vTexcoord + vec2(0.,  tx.y) ).a; if(a > 0.) gl_FragColor = v_vColour;
    a = texture2D( gm_BaseTexture, v_vTexcoord + vec2(0., -tx.y) ).a; if(a > 0.) gl_FragColor = v_vColour;
}
