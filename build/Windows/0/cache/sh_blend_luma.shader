//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
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

uniform vec2 dimension;
uniform int tile_type;

uniform int useMask;
uniform int preserveAlpha;
uniform sampler2D mask;
uniform sampler2D fore;
uniform float opacity;

float sampleMask() {
	if(useMask == 0) return 1.;
	vec4 m = texture2D( mask, v_vTexcoord );
	return (m.r + m.g + m.b) / 3. * m.a;
}

float hue2rgb( in float m1, in float m2, in float hue) { 
	if (hue < 0.0)
		hue += 1.0;
	else if (hue > 1.0)
		hue -= 1.0;

	if ((6.0 * hue) < 1.0)
		return m1 + (m2 - m1) * hue * 6.0;
	else if ((2.0 * hue) < 1.0)
		return m2;
	else if ((3.0 * hue) < 2.0)
		return m1 + (m2 - m1) * ((2.0 / 3.0) - hue) * 6.0;
	else
		return m1;
} 

vec3 hsl2rgb( in vec3 hsl ) { 
	float r, g, b;
	if(hsl.y == 0.) {
		r = hsl.z;
		g = hsl.z;
		b = hsl.z;
	} else {
		float m1, m2;
		if(hsl.z <= 0.5)
			m2 = hsl.z * (1. + hsl.y);
		else 
			m2 = hsl.z + hsl.y - hsl.z * hsl.y;
		m1 = 2. * hsl.z - m2;
		
		r = hue2rgb(m1, m2, hsl.x + 1. / 3.);
		g = hue2rgb(m1, m2, hsl.x);
		b = hue2rgb(m1, m2, hsl.x - 1. / 3.);
	}
	
	return vec3( r, g, b );
} 

vec3 rgb2hsl( in vec3 c ) { 
	float h = 0.0;
	float s = 0.0;
	float l = 0.0;
	float r = c.r;
	float g = c.g;
	float b = c.b;
	float cMin = min( r, min( g, b ) );
	float cMax = max( r, max( g, b ) );

	l = ( cMax + cMin ) / 2.0;
	if ( cMax > cMin ) {
		float cDelta = cMax - cMin;
		
		s = l < .5 ? cDelta / ( cMax + cMin ) : cDelta / ( 2.0 - ( cMax + cMin ) );
		
		if ( r == cMax )
			h = ( g - b ) / cDelta;
		else if ( g == cMax )
			h = 2.0 + ( b - r ) / cDelta;
		else
			h = 4.0 + ( r - g ) / cDelta;
		
		if ( h < 0.0)
			h += 6.0;
		h = h / 6.0;
	}
	return vec3( h, s, l );
} 

void main() {
	vec4 _col0 = texture2D( gm_BaseTexture, v_vTexcoord );
	vec3 _hsl0 = rgb2hsl(_col0.rgb);
	
	vec2 fore_tex = v_vTexcoord;
	if(tile_type == 0)
		fore_tex = v_vTexcoord;
	else if(tile_type == 1)
		fore_tex = fract(v_vTexcoord * dimension);
	
	vec4 _col1 = texture2D( fore, fore_tex );
	vec3 _hsl1 = rgb2hsl(_col1.rgb);
	
	_hsl0.z = mix(_hsl0.z, _hsl1.z, _col1.a * opacity * sampleMask());
	
	float al = _col1.a + _col0.a * (1. - _col1.a);
	vec4 res = vec4(hsl2rgb(_hsl0), _col0.a);
	res.rgb /= al;
	res.a = preserveAlpha == 1? _col0.a : res.a;
	
	gl_FragColor = res;
}

