#define TAU 6.283185307179586

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float intensity;
uniform float height;
uniform int   pixel;

float h(vec4 c) { return (c.r + c.g + c.b) / 3. * c.a; }

void main() {
    vec2  tx = 1. / dimension;
    float dd = length(tx);
    float ch = h(texture2D( gm_BaseTexture, v_vTexcoord ));
    float aa = 0.;
    
    float base = 1.;
	float top  = 0.;
    	
	for(float j = 0.; j <= 64.; j++) {
		float ang = pixel == 1? top / base * TAU : j / 64. * TAU;
		float ad  = 0.;
		
		top += 2.;
		if(top >= base) {
			top   = 1.;
			base *= 2.;
		}
	    
	    for(float i = 0.; i <= height; i++) {
        	
    		vec2 txs = v_vTexcoord + vec2( cos(ang),  sin(ang)) * i * tx;
    		float hh = h(texture2D( gm_BaseTexture, txs ));
    		
    		float dh = (hh - ch) * height;
    		float di = (dh - i) / dh;
    		float ao = max(0., hh - ch) * di * intensity;
    		
    		ad = max(ad, ao);
    	}
    	
    	aa += ad / 64.;
	}
	
	gl_FragColor = vec4(vec3(max(.0, 1. - aa)), 1.);
}
