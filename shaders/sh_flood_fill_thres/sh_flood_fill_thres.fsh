varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform int   mode;
uniform vec2  position;
uniform vec4  refColor;

uniform int   channel;
uniform float thres;

void main() {
    vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
    
    float dis   = 0.;
    int   chan  = channel;
    vec4  color = refColor;
    
    if(mode == 0) color = texture2D( gm_BaseTexture, position / dimension );
    
    if(chan >= 8) {
    	dis  += pow( col.a - color.a, 2.);
    	chan -= 8;
    }
    
    if(chan >= 4) {
    	dis  += pow( col.b - color.b, 2.);
    	chan -= 4;
    }
    
    if(chan >= 2) {
    	dis  += pow( col.g - color.g, 2.);
    	chan -= 2;
    }
    
    if(chan >= 1) {
    	dis  += pow( col.r - color.r, 2.);
    	chan -= 1;
    }
    
    dis = sqrt(dis);
    
	float n = step(dis, thres);
	gl_FragColor = vec4(vec3(0.), n);
}
