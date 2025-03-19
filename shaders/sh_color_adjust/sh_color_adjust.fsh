varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int use_mask;
uniform sampler2D mask;

uniform sampler2D param0;
uniform sampler2D param1;

uniform vec2 brightness;
uniform int  brightnessUseSurf;

uniform vec2 contrast;
uniform int  contrastUseSurf;

uniform vec2 exposure;
uniform int  exposureUseSurf;

uniform vec2 hue;
uniform int  hueUseSurf;

uniform vec2 sat;
uniform int  satUseSurf;

uniform vec2 val;
uniform int  valUseSurf;

uniform vec2 alpha;
uniform int  alphaUseSurf;

uniform vec4 blend;
uniform vec2 blendAmount;
uniform int  blendAmountUseSurf;
uniform int  blendMode;

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
#endregion =========================================== COLORS SPACES ===========================================

void main() {
    vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
    
	#region get param
		vec2 htx = v_vTexcoord * 0.5;
	
		float bri = brightness.x;
		if(brightnessUseSurf == 1) {
			vec4 _vMap = texture2D( param0, htx );
			bri = mix(brightness.x, brightness.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float exo = exposure.x;
		if(exposureUseSurf == 1) {
			vec4 _vMap = texture2D( param0, vec2(0.5, 0.0) + htx );
			exo = mix(exposure.x, exposure.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float con = contrast.x;
		if(contrastUseSurf == 1) {
			vec4 _vMap = texture2D( param0, vec2(0.0, 0.5) + htx );
			con = mix(contrast.x, contrast.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float hhe = hue.x;
		if(hueUseSurf == 1) {
			vec4 _vMap = texture2D( param0, vec2(0.5, 0.5) + htx );
			hhe = mix(hue.x, hue.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float sst = sat.x;
		if(satUseSurf == 1) {
			vec4 _vMap = texture2D( param1, htx );
			sst = mix(sat.x, sat.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float vvl = val.x;
		if(valUseSurf == 1) {
			vec4 _vMap = texture2D( param1, vec2(0.5, 0.0) + htx );
			vvl = mix(val.x, val.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float bld = blendAmount.x;
		if(blendAmountUseSurf == 1) {
			vec4 _vMap = texture2D( param1, vec2(0.0, 0.5) + htx );
			bld = mix(blendAmount.x, blendAmount.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float alp = alpha.x;
		if(alphaUseSurf == 1) {
			vec4 _vMap = texture2D( param1, vec2(0.5, 0.5) + htx );
			alp = mix(alpha.x, alpha.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
	#endregion
	
	//contrast
	vec4 col_c = .5 + (con * 2.) * (col - .5);
	col_c = clamp(col_c, vec4(0.), vec4(1.));
	
	//brightness
	vec4 col_cb = col_c + vec4(bri, bri, bri, 0.0);
	col_cb = clamp(col_cb, vec4(0.), vec4(1.));
	
	//exposure
	col_cb = clamp(col_cb * exo, vec4(0.), vec4(1.));
	
	//hsv
	vec3 _hsv = rgb2hsv(col_cb.rgb);
	_hsv.x = clamp(_hsv.x + hhe, -1., 1.);
	_hsv.z = clamp((_hsv.z + vvl) * (1. + sst * _hsv.y * .5), 0., 1.);
	_hsv.y = clamp(_hsv.y * (sst + 1.), 0., 1.);
	
	vec3 _col_cbh = hsv2rgb(_hsv);
	vec4 col_cbh = vec4(_col_cbh.r, _col_cbh.g, _col_cbh.b, col.a);
	col_cbh = clamp(col_cbh, vec4(0.), vec4(1.));
	
	//blend
	vec3  col3 = col_cbh.rgb;
	vec3  bld3 = blend.rgb;
	vec3  bmix = blend.rgb;
	
	vec3  chsv = rgb2hsv(col3);
	vec3  bhsv = rgb2hsv(bld3);
	
	float lum  = dot(col3, vec3(0.2126, 0.7152, 0.0722));
	
	     if(blendMode == 0)	bmix = bld3;
	else if(blendMode == 1) bmix = col3 + bld3;
	else if(blendMode == 2) bmix = col3 - bld3;
	else if(blendMode == 3) bmix = col3 * bld3;
	else if(blendMode == 4) bmix = 1. - (1. - col3) * (1. - bld3);
	
	else if(blendMode == 5) bmix = lum > 0.5? (1. - (1. - 2. * (col3 - 0.5)) * (1. - bld3)) : ((2. * col3) * bld3);
	else if(blendMode == 6) bmix = hsv2rgb(vec3(bhsv.r, chsv.g, chsv.b));
	else if(blendMode == 7) bmix = hsv2rgb(vec3(chsv.r, mix(chsv.g, bhsv.g, bld), chsv.b));
	else if(blendMode == 8) { 
		vec3 chsl = rgb2hsl(col3);
		vec3 bhsl = rgb2hsl(bld3);
		chsl.z    = mix(chsl.z, bhsl.z, bld);
		bmix      = hsl2rgb(chsl);
	}
	else if(blendMode == 9) {
		bmix.r = max(col3.r, bld3.r);
		bmix.g = max(col3.g, bld3.g);
		bmix.b = max(col3.b, bld3.b);
	}
	
	else if(blendMode == 10) {
		bmix.r = min(col3.r, bld3.r);
		bmix.g = min(col3.g, bld3.g);
		bmix.b = min(col3.b, bld3.b);
	}
	
	else if(blendMode == 11) bmix = bld3;
	else if(blendMode == 12) bmix = abs(col3 - bld3);
	
	if(blendMode != 7 && blendMode != 8)
		col_cbh.rgb = mix(col_cbh.rgb, bmix, bld);
	else 
		col_cbh.rgb = bmix;
	
	//mask
	if(use_mask == 1) {
		vec4 mas = texture2D( mask, v_vTexcoord );
		mas.rgb *= mas.a;
		gl_FragColor = col_cbh * mas + col * (vec4(1.) - mas);
		gl_FragColor.a = col.a * mix(1., alp, mas.r);
	} else {
		gl_FragColor = col_cbh;
		gl_FragColor.a = col.a * alp;
	}
}
