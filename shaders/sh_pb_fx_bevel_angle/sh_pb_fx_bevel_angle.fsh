varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;

float val(vec4 v) { return (v.r + v.g + v.b) / 3. * v.a; }

void main() {
    vec2 tx = 1. / dimension;
    vec4 cc = texture2D( gm_BaseTexture, v_vTexcoord );
    gl_FragColor = vec4(0.);
    if(val(cc) == 0.) return;
    
    bool l = val(texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tx.x, 0.) )) != 0.;
    bool r = val(texture2D( gm_BaseTexture, v_vTexcoord + vec2( tx.x, 0.) )) != 0.;
    if(l && r) { gl_FragColor = vec4(0., 0., 0., 1.); return; }
    
    bool u = val(texture2D( gm_BaseTexture, v_vTexcoord + vec2(0., -tx.y) )) != 0.;
    bool d = val(texture2D( gm_BaseTexture, v_vTexcoord + vec2(0.,  tx.y) )) != 0.;
    if(u && d) { gl_FragColor = vec4(.5, 0., 0., 1.); return; }
    
    bool ru = val(texture2D( gm_BaseTexture, v_vTexcoord + vec2( tx.x, -tx.y) )) != 0.;
    bool ld = val(texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tx.x,  tx.y) )) != 0.;
    if(ru || ld) { gl_FragColor = vec4(.25, 0., 0., 1.); return; }
    
    bool lu = val(texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tx.x, -tx.y) )) != 0.;
    bool rd = val(texture2D( gm_BaseTexture, v_vTexcoord + vec2( tx.x,  tx.y) )) != 0.;
    if(lu || rd) { gl_FragColor = vec4(.75, 0., 0., 1.); return; }
    
    if(l || r) { gl_FragColor = vec4(0., 0., 0., 1.); return; }
    if(u || d) { gl_FragColor = vec4(.5, 0., 0., 1.); return; }
}
