#ifdef _YY_HLSL11_ 
	#define PALETTE_LIMIT 1024 
#else 
	#define PALETTE_LIMIT 256 
#endif

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int  type;
uniform vec2 range;

uniform float hue;
uniform float sat;
uniform float val;
uniform float red;
uniform float green;
uniform float blue;

uniform int  discretize;
uniform vec4 palette[PALETTE_LIMIT];
uniform int  paletteAmount;

#region =========================================== COLORS SPACES ===========================================
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

	vec3 rgb2oklab(vec3 c) {
		const mat3 kCONEtoLMS = mat3(                
	         0.4121656120,  0.2118591070,  0.0883097947,
	         0.5362752080,  0.6807189584,  0.2818474174,
	         0.0514575653,  0.1074065790,  0.6302613616);
	    
		c = pow(c, vec3(2.2));
		c = pow( kCONEtoLMS * c, vec3(1.0 / 3.0) );
		
		return c;
	}

	vec3 rgb2oklch(vec3 c) {
		vec3 lab = rgb2oklab(c);
		float C = sqrt(lab.y * lab.y + lab.z * lab.z);
		float h = atan(lab.z, lab.y);
		if (h < 0.) h += 6.28318530718;
		return vec3(lab.x, C, h);
	}
	
	vec3 oklab2rgb(vec3 c) {
		const mat3 kLMStoCONE = mat3(
	         4.0767245293, -1.2681437731, -0.0041119885,
	        -3.3072168827,  2.6093323231, -0.7034763098,
	         0.2307590544, -0.3411344290,  1.7068625689);
        
		c = kLMStoCONE * (c * c * c);
		c = pow(c, vec3(1. / 2.2));
		
	    return c;
	}
	
	vec3 oklch2rgb(vec3 c) {
		float a = cos(c.z) * c.y;
		float b = sin(c.z) * c.y;
		return oklab2rgb(vec3(c.x, a, b));
	}
#endregion =========================================== COLORS SPACES ===========================================

void main() {
	vec4  base = texture2D(gm_BaseTexture, v_vTexcoord);
	vec3  cc   = vec3(0.);
	float v    = mix(range.x, range.y, v_vTexcoord.x);
	
	vec3 rgb = vec3(red, green, blue);
	vec3 lch = rgb2oklch(rgb);
	
		 if(type == 0) cc = hsv2rgb(vec3(  v, sat, val));
	else if(type == 1) cc = hsv2rgb(vec3(hue,   v, val));
	else if(type == 2) cc = hsv2rgb(vec3(hue, sat,   v));
	
	else if(type == 3) cc = vec3(  v, green, blue);
	else if(type == 4) cc = vec3(red,     v, blue);
	else if(type == 5) cc = vec3(red, green,    v);
	
	else if(type == 6) cc = oklch2rgb(vec3(    v, lch.g, lch.b));
	else if(type == 7) cc = oklch2rgb(vec3(lch.r,     v, lch.b));
	else if(type == 8) cc = oklch2rgb(vec3(lch.r, lch.g,     v));
	
	vec4 c = type == 99? vec4(red, green, blue, v) : vec4(cc, base.a);
	
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