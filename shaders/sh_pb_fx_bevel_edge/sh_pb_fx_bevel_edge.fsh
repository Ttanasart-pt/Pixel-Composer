varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;

float val(vec4 v) { return (v.r + v.g + v.b) / 3. * v.a; }

void main() {
    vec2 tx = 1. / dimension;
    vec4 cc = texture2D( gm_BaseTexture, v_vTexcoord );
    
    gl_FragColor = vec4(0.);
    if(val(cc) != 0.) return;
    
    vec4 c0 = texture2D( gm_BaseTexture, v_vTexcoord + vec2( tx.x, 0.) );
    if(val(c0) == 1.) { gl_FragColor = vec4(1.); return; }
    
    vec4 c1 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tx.x, 0.) );
    if(val(c1) == 1.) { gl_FragColor = vec4(1.); return; }
    
    vec4 c2 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(0.,  tx.y) );
    if(val(c2) == 1.) { gl_FragColor = vec4(1.); return; }
    
    vec4 c3 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(0., -tx.y) );
    if(val(c3) == 1.) { gl_FragColor = vec4(1.); return; }
    
}
