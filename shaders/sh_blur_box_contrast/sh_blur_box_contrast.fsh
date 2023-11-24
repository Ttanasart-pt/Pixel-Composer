//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D baseSurface;
uniform vec2  dimension;
uniform float size;
uniform float treshold;
uniform int   direction;

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
	vec3 lab1 = rgb2lab(c1.rgb * c1.a);
	vec3 lab2 = rgb2lab(c2.rgb * c2.a);
	
	return length(lab1 - lab2);
}

void main() {
	vec4 base_col = texture2D( baseSurface, v_vTexcoord);
	vec4 curr_col = texture2D( gm_BaseTexture, v_vTexcoord);
	
	if(base_col.a > 0.5) {
		vec4 col = curr_col;
		vec4 _bcol, _ccol;
		float mulp = 1.;
	
		if(direction == 0) {
			for(float i = 1.; i < 32.; i++) {
				if(i >= size) break;
				
				_bcol = texture2D( baseSurface, v_vTexcoord + vec2(i / dimension.x, 0.));
				if(_bcol.a > 0.5 && colorDifferent(base_col, _bcol) < treshold) {
					_ccol = texture2D( gm_BaseTexture, v_vTexcoord + vec2(i / dimension.x, 0.));
					col += _ccol;
					mulp++;
				}
				
				_bcol = texture2D( baseSurface, v_vTexcoord - vec2(i / dimension.x, 0.));
				if(_bcol.a > 0.5 && colorDifferent(base_col, _bcol) < treshold) {
					_ccol = texture2D( gm_BaseTexture, v_vTexcoord - vec2(i / dimension.x, 0.));
					col += _ccol;
					mulp++;
				}
			}
		
			col /= mulp;
		} else if(direction == 1) {
			for(float i = 1.; i < 32.; i++) {
				if(i >= size) break;
				
				_bcol = texture2D( baseSurface, v_vTexcoord + vec2(0., i / dimension.y));
				if(_bcol.a > 0.5 && colorDifferent(base_col, _bcol) < treshold) {
					_ccol = texture2D( gm_BaseTexture, v_vTexcoord + vec2(0., i / dimension.y));
					col += _ccol;
					mulp++;
				}
				
				_bcol = texture2D( baseSurface, v_vTexcoord - vec2(0., i / dimension.y));
				if(_bcol.a > 0.5 && colorDifferent(base_col, _bcol) < treshold) {
					_ccol = texture2D( gm_BaseTexture, v_vTexcoord - vec2(0., i / dimension.y));
					col += _ccol;
					mulp++;
				}
			}
		
			col /= mulp;
		}
		
		col.a = base_col.a;
		gl_FragColor = col;
	} else {
		gl_FragColor = base_col;
	}
}
