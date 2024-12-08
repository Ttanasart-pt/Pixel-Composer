//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define TAU 6.283185307179586
#define MAX_STRENGTH 64.

uniform vec2  dimension;
uniform float size;
uniform float treshold;
uniform int   direction;
uniform int   gamma;

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
	return length(c1.rgb - c2.rgb) / 1.7320508076;
} 

void main() {
	vec2  tx  = 1. / dimension;
	vec4  col = texture2D( gm_BaseTexture, v_vTexcoord);
	vec4  c   = col;
	float div = 1.;
	float sz2 = size * size;
	
	for(float i = -MAX_STRENGTH; i <= MAX_STRENGTH; i++)
	for(float j = -MAX_STRENGTH; j <= MAX_STRENGTH; j++) {
		float dist = i * i + j * j;
		if(dist >= sz2) continue;
		
		float amp = 1. - dist / sz2;
		vec2 pxs  = v_vTexcoord + vec2( i, j ) * tx;
		vec4 bcol = texture2D( gm_BaseTexture, pxs);
		
		if(c.a == bcol.a && colorDifferent(c, bcol) <= treshold) {
			if(gamma == 1) bcol.rgb = pow(bcol.rgb, vec3(2.2));
			
			col += bcol * amp;
			div += amp;
		}
	}
	
	vec4 res = col / div;
	if(gamma == 1) res.rgb = pow(res.rgb, vec3(1. / 2.2));
	
	gl_FragColor = res;
}

