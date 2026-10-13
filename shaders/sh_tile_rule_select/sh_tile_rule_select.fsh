varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;

uniform int   selectionSize;
uniform float selection[64];
uniform float selectionGroup[640];

void main() {
    vec2 tx   = 1. / dimension;
    vec4 base = texture2D( gm_BaseTexture, v_vTexcoord );
    float bs  = base.r - 1.;
    gl_FragColor = vec4(0.);
    
    if(bs == -1.) return;
    
    for(int i = 0; i < selectionSize; i++) {
        float selInd = selection[i];
        if(selInd < 10000.) continue;
        
        int _arr = int(selInd - 10000.);
        int _len = int(selectionGroup[_arr * 64]);
        
        for(int k = 0; k < _len; k++) {
            float _subI = selectionGroup[_arr * 64 + 1 + k];
            if(_subI == -1.) continue;
            
            if(bs == _subI) {
                gl_FragColor = vec4(selInd, 0., 0., 1.);
                return;
            }
        }
    }
    
}
