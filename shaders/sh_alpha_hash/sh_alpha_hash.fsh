//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D map;
uniform vec2 mapDimension;
uniform int useMap;

uniform vec2 dimension;
uniform float ditherSize;
uniform float dither[64];

void main() {
    vec4 c = texture2D( gm_BaseTexture, v_vTexcoord );
	
	if(c.a == 1.) {
		gl_FragColor = c;
		return;
	}
	
	vec2 pos = floor(v_vTexcoord * dimension);
	float val;
	
	if(useMap == 0) {
		float col = mod(pos.x, ditherSize);
		float row = mod(pos.y, ditherSize);
	
		val = dither[int(row * ditherSize + col)] / (ditherSize * ditherSize - 1.);
	} else {
		float col = mod(pos.x, mapDimension.x);
		float row = mod(pos.y, mapDimension.y);
		vec4 map_data = texture2D( map, vec2(col, row) / mapDimension );
		
		val = dot(map_data.rgb, vec3(0.2126, 0.7152, 0.0722));
	} 
	
	c.a = c.a > val? 1. : 0.;
	
	gl_FragColor = c;
}
