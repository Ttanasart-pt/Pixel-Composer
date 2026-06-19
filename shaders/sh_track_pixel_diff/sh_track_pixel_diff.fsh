#pragma use(sampler_simple)

#region -- sampler_simple -- [1765194569.6586206]
    uniform int  sampleMode;
    
    uniform sampler2D uvMap;
    uniform int   useUvMap;
    uniform float uvMapMix;

    vec2 getUV(vec2 tx) {
        if(useUvMap == 1) {
            vec2 map = texture2D(uvMap, tx).xy;
            map.y    = 1.0 - map.y;
            tx       = mix(tx, map, uvMapMix);
        }
        return tx;
    }

    vec4 sampleTexture( sampler2D texture, vec2 pos, float mapBlend) {
        if(useUvMap == 1) {
            vec2 map = texture2D(uvMap, pos).xy;
            map.y    = 1.0 - map.y;
            pos      = mix(pos, map, mapBlend * uvMapMix);
        }

        if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
            return texture2D(texture, pos);
        
			 if(sampleMode <= 1) return vec4(0.);
		else if(sampleMode == 2) return vec4(0.,0.,0., 1.);
		else if(sampleMode == 3) return texture2D(texture, clamp(pos, 0., 1.));
		else if(sampleMode == 4) return texture2D(texture, fract(pos));
        // 5
		else if(sampleMode == 6) { vec2 sp = vec2(fract(pos.x), pos.y); return (sp.y < 0. || sp.y > 1.) ? vec4(0.) : texture2D(texture, sp); } 
		else if(sampleMode == 7) { vec2 sp = vec2(fract(pos.x), pos.y); return (sp.y < 0. || sp.y > 1.) ? vec4(0.,0.,0.,1.) : texture2D(texture, sp); } 
		else if(sampleMode == 8) return texture2D(texture, vec2(fract(pos.x), clamp(pos.y, 0., 1.)));
		// 9
		else if(sampleMode == 10) { vec2 sp = vec2(pos.x, fract(pos.y)); return (sp.x < 0. || sp.x > 1.) ? vec4(0.) : texture2D(texture, sp); } 
		else if(sampleMode == 11) { vec2 sp = vec2(pos.x, fract(pos.y)); return (sp.x < 0. || sp.x > 1.) ? vec4(0.,0.,0.,1.) : texture2D(texture, sp); } 
		else if(sampleMode == 12) return texture2D(texture, vec2(clamp(pos.x, 0., 1.), fract(pos.y)));
		
        return vec4(0.);
    }
    vec4 sampleTexture( sampler2D texture, vec2 pos) { return sampleTexture(texture, pos, 0.); }
#endregion -- sampler_simple --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec2  offset;

uniform sampler2D trackTarget;
uniform float windowSize;
uniform float scanSize;
uniform float colorTolr;

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

	float colorDifferentLAB(in vec4 c1, in vec4 c2) {
		vec3 lab1 = rgb2lab(c1.rgb);
		vec3 lab2 = rgb2lab(c2.rgb);
		
		return length(lab1 - lab2);
	}
	
	float colorDifferentRGB(in vec4 c1, in vec4 c2) {
		return length(c1.rgb - c2.rgb);
	}

#endregion =========================================== COLORS SPACES ===========================================

void main() {
	
	float winSiz = windowSize * 2. + 1.;
	float scaSiz = scanSize   * 2. + 1.;
	
	vec2 offs   = offset / dimension;
	vec2 targTx = 1. / vec2(winSiz);
	vec2 baseTx = 1. / dimension;
	
	float delt = 0.;
	float divv = 0.;
	
	vec4 targSamp;
	vec4 baseSamp;

	for(float i = -windowSize; i < windowSize; i++) 
	for(float j = -windowSize; j < windowSize; j++) {
		float _dist = 1.;//max(0., length(vec2(i,j)) / windowSize);
		
		vec2 targSx = (.5 + vec2(i,j) + windowSize) * targTx;
		targSamp = texture2D(trackTarget, targSx);
		
		vec2 baseSx = v_vTexcoord - offs + vec2(i,j) * baseTx;
		baseSamp = sampleTexture(gm_BaseTexture, baseSx);
		
		float _diff = colorDifferentLAB(targSamp, baseSamp);
		float _delt = _diff >= colorTolr? 1. : 0.;
		
		// vec3 tval = targSamp.rgb * targSamp.a;
		// vec3 bval = baseSamp.rgb * baseSamp.a;
		
		// float _delt = distance(tval, bval);
		
		delt += _delt * _dist;
		divv += _dist;
	}
	
	delt /= divv;
	
	gl_FragColor = vec4(delt, v_vTexcoord, 1.);
}