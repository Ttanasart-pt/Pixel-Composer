//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D map;
uniform vec2 mapDimension;
uniform int useMap;

uniform float contrast;
uniform sampler2D conMap;
uniform int useConMap;

uniform float ditherSize;
uniform float dither[64];
uniform vec2  dimension;
uniform vec4  palette[32];
uniform int   keys;

vec3 rgb2xyz( vec3 c ) {
    vec3 tmp;
    tmp.x = ( c.r > 0.04045 ) ? pow( ( c.r + 0.055 ) / 1.055, 2.4 ) : c.r / 12.92;
    tmp.y = ( c.g > 0.04045 ) ? pow( ( c.g + 0.055 ) / 1.055, 2.4 ) : c.g / 12.92,
    tmp.z = ( c.b > 0.04045 ) ? pow( ( c.b + 0.055 ) / 1.055, 2.4 ) : c.b / 12.92;
    return 100.0 * tmp *
        mat3( 0.4124, 0.3576, 0.1805,
              0.2126, 0.7152, 0.0722,
              0.0193, 0.1192, 0.9505 );
}

vec3 xyz2lab( vec3 c ) {
    vec3 n = c / vec3( 95.047, 100, 108.883 );
    vec3 v;
    v.x = ( n.x > 0.008856 ) ? pow( n.x, 1.0 / 3.0 ) : ( 7.787 * n.x ) + ( 16.0 / 116.0 );
    v.y = ( n.y > 0.008856 ) ? pow( n.y, 1.0 / 3.0 ) : ( 7.787 * n.y ) + ( 16.0 / 116.0 );
    v.z = ( n.z > 0.008856 ) ? pow( n.z, 1.0 / 3.0 ) : ( 7.787 * n.z ) + ( 16.0 / 116.0 );
    return vec3(( 116.0 * v.y ) - 16.0, 500.0 * ( v.x - v.y ), 200.0 * ( v.y - v.z ));
}

vec3 rgb2lab(vec3 c) {
    vec3 lab = xyz2lab( rgb2xyz( c ) );
    return vec3( lab.x / 100.0, 0.5 + 0.5 * ( lab.y / 127.0 ), 0.5 + 0.5 * ( lab.z / 127.0 ));
}

float colorDifferent(in vec4 c1, in vec4 c2) {
	vec3 lab1 = rgb2lab(c1.rgb);
	vec3 lab2 = rgb2lab(c2.rgb);
	
	return length(lab1 - lab2);
}

void main() {
	vec4 _col = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	
	bool exactColor = false;
	int closet1_index = 0;
	int closet2_index = 0;
	float closet1_value = 99.;
	float closet2_value = 99.;
	
	for(int i = 0; i < keys; i++) {
		vec4 p_col = palette[i];
		float dif = colorDifferent(p_col, _col);
		
		if(dif <= 0.001) {
			exactColor = true;
			_col = p_col;
		} else if(dif < closet1_value) {
			closet2_value = closet1_value;
			closet2_index = closet1_index;
			
			closet1_value = dif;
			closet1_index = i;
		} else if(dif < closet2_value) {
			closet2_value = dif;
			closet2_index = i;	
		}
	}
	
	if(exactColor) {
		gl_FragColor = _col;
	} else {
		vec4 col1 = palette[closet1_index];
		vec4 col2 = palette[closet2_index];
		float d1 = colorDifferent(_col, col1);
		float d2 = colorDifferent(_col, col2);
		float rat = d1 / (d1 + d2);
		
		if(useConMap == 0) {
			rat = (rat - 0.5) * contrast + 0.5;
		} else {
			vec4 con_map_data = texture2D( conMap, v_vTexcoord );
			float _cont = .1 + contrast * dot(con_map_data.rgb, vec3(0.2126, 0.7152, 0.0722));
			rat = (rat - 0.5) * _cont + 0.5;
		}
		
		vec2 pixelPos = v_vTexcoord * dimension;
		pixelPos.x = floor(pixelPos.x);
		pixelPos.y = floor(pixelPos.y);
	
		if(useMap == 0) {
			float col = pixelPos.x - floor(pixelPos.x / ditherSize) * ditherSize;
			float row = pixelPos.y - floor(pixelPos.y / ditherSize) * ditherSize;
	
			float ditherVal = dither[int(row * ditherSize + col)] / (ditherSize * ditherSize - 1.);
	
			if(rat <= 1. / (ditherSize * ditherSize) || rat < ditherVal) 
				gl_FragColor = col1;
			else
				gl_FragColor = col2;	
		} else {
			float col = pixelPos.x - floor(pixelPos.x / mapDimension.x) * mapDimension.x;
			float row = pixelPos.y - floor(pixelPos.y / mapDimension.y) * mapDimension.y;
			vec4 map_data = texture2D( map, vec2(col, row) / mapDimension );
		
			float ditherVal = dot(map_data.rgb, vec3(0.2126, 0.7152, 0.0722));
		
			if(rat <= 1. / (ditherSize * ditherSize) || rat < ditherVal) 
				gl_FragColor = col1;
			else
				gl_FragColor = col2;
		}
	}
	
	gl_FragColor.a *= _col.a;
}
