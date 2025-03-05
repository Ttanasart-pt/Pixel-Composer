varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;

void main() {
    vec2 tx = 1. / dimension;
    vec4 cc = texture2D( gm_BaseTexture, v_vTexcoord );
    gl_FragColor = vec4(0.);
    if(cc.a == 0.) return;
    
    bool l = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tx.x, 0.) ).a != 0.;
    bool r = texture2D( gm_BaseTexture, v_vTexcoord + vec2( tx.x, 0.) ).a != 0.;
    if(l && r) { gl_FragColor = vec4(0., 0., 0., 1.); return; }
    
    bool u = texture2D( gm_BaseTexture, v_vTexcoord + vec2(0., -tx.y) ).a != 0.;
    bool d = texture2D( gm_BaseTexture, v_vTexcoord + vec2(0.,  tx.y) ).a != 0.;
    if(u && d) { gl_FragColor = vec4(.5, 0., 0., 1.); return; }
    
    bool ru = texture2D( gm_BaseTexture, v_vTexcoord + vec2( tx.x, -tx.y) ).a != 0.;
    bool ld = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tx.x,  tx.y) ).a != 0.;
    if(ru || ld) { gl_FragColor = vec4(.25, 0., 0., 1.); return; }
    
    bool lu = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tx.x, -tx.y) ).a != 0.;
    bool rd = texture2D( gm_BaseTexture, v_vTexcoord + vec2( tx.x,  tx.y) ).a != 0.;
    if(lu || rd) { gl_FragColor = vec4(.75, 0., 0., 1.); return; }
    
    if(l || r) { gl_FragColor = vec4(0., 0., 0., 1.); return; }
    if(u || d) { gl_FragColor = vec4(.5, 0., 0., 1.); return; }
}
