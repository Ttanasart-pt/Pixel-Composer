#define PALETTE_LIMIT 1024

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int mode;
uniform float hue;
uniform float val;
uniform float sat;

uniform int  discretize;
uniform vec4 palette[PALETTE_LIMIT];
uniform int  paletteAmount;

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
	vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 c;
	
    	 if(mode == 0) c = vec4(hsv2rgb(vec3(hue, v_vTexcoord.x, 1. - v_vTexcoord.y)), col.a);
	else if(mode == 1) c = vec4(hsv2rgb(vec3(v_vTexcoord.x, 1. - v_vTexcoord.y, val)), col.a);
	else if(mode == 2) c = vec4(hsv2rgb(vec3(v_vTexcoord.x, sat, 1. - v_vTexcoord.y)), col.a);
		
	if(discretize == 1) {
		int index = 0;
		float minDist = 999.;
		for(int i = 0; i < paletteAmount; i++) {
			float dist = distance(c.rgb, palette[i].rgb);
			
			if(dist < minDist) {
				minDist = dist;
				index = i;
			}
		}
		
		c = palette[index];
	}
	
	gl_FragColor = c;
}
