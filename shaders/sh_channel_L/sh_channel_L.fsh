varying vec2 v_vTexcoord;
varying vec4 v_vColour;

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
	vec4 col = texture2D( gm_BaseTexture, v_vTexcoord);
	vec3 hsl = rgb2hsl(col.rgb);
    
	gl_FragColor = vec4(hsl.b, hsl.b, hsl.b, col.a);
}
