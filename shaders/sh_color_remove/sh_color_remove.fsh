#define PALETTE_LIMIT 1024
//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4	colorFrom[PALETTE_LIMIT];
uniform int		colorFrom_amo;
uniform int		invert;

uniform vec2      treshold;
uniform int       tresholdUseSurf;
uniform sampler2D tresholdSurf;

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

void main() {
	float trh = treshold.x;
	if(tresholdUseSurf == 1) {
		vec4 _vMap = texture2D( tresholdSurf, v_vTexcoord );
		trh = mix(treshold.x, treshold.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
    vec4 col = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 baseColor;
	baseColor = col;
		
	vec3 lab = rgb2lab(col.rgb);
	
	float min_df = 999.;
	for(int i = 0; i < colorFrom_amo; i++) {
		vec3 labFrom = rgb2lab(colorFrom[i].rgb);
	
		float df = length(lab - labFrom);
		min_df = min(min_df, df);
	}
	
	if((invert == 0 && min_df <= trh) || (invert == 1 && min_df > trh))
		gl_FragColor = vec4(0.);
	else	
		gl_FragColor = baseColor;
}
