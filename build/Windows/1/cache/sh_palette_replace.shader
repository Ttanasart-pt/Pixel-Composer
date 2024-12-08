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
//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int		  useMask;
uniform sampler2D mask;

#ifdef _YY_HLSL11_ 
	#define PALETTE_LIMIT 1024 
#else 
	#define PALETTE_LIMIT 256 
#endif
uniform vec4	colorFrom[PALETTE_LIMIT];
uniform int		colorFrom_amo;
uniform vec4	colorTo[PALETTE_LIMIT];
uniform int		colorTo_amo;

uniform float   seed;
uniform int		mode;

uniform int		inverted;
uniform int		alphacmp;
uniform int		hardReplace;
uniform float	treshold;



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
	
	vec3 rgb2hsv(vec3 c) {
		vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	
	    float d = q.x - min(q.w, q.y);
	    float e = 0.0000000001;
	    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
	 }
	
	vec3 hsv2rgb(vec3 c) {
	    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
	}



float random(in float st) { return fract(sin(st * 12.9898) * (seed + 43758.5453123)); }
float round(float val)    { return fract(val) >= 0.5? ceil(val) : floor(val); }

void main() {
    vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 baseColor;
	if(inverted == 0)
		baseColor = col;
	else if(inverted == 1) {
		baseColor = vec4(vec3(0.), 1.);
		
		if(useMask == 1) {
			vec4 m = texture2D( mask, v_vTexcoord );
			if((m.r + m.g + m.b) * m.a < .5) {
				gl_FragColor = baseColor;
				return;
			}
		}
	}

	vec3 hsv = rgb2hsv(col.rgb);
	if(alphacmp == 1) hsv *= col.a;
	
	float min_df = treshold;
	int min_index = 0;
	
	for(int i = 0; i < colorFrom_amo; i++) {
		vec3 hsvFrom = rgb2hsv(colorFrom[i].rgb);
	
		float df = length(hsv - hsvFrom);
		if(df < min_df) {
			min_df = df;
			min_index = i;
		}
	}
	
	vec4 clr = vec4(0.);
	
		 if(mode == 0) clr = colorTo[int(round(float(min_index) / float(colorFrom_amo - 1) * float(colorTo_amo - 1)))];
	else if(mode == 1) clr = colorTo[int(round(random(float(min_index)) * float(colorTo_amo - 1)))];
	
	if(min_df < treshold) {
		if(hardReplace == 0) {
			float rat = min_df / treshold;
			gl_FragColor = baseColor * (rat) + clr * (1. - rat);
		} else 
			gl_FragColor = clr;
	} else	
		gl_FragColor = baseColor;
	
	if(inverted == 0)
		gl_FragColor.a = col.a;
}

