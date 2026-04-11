#ifdef _YY_HLSL11_ 
	#define PALETTE_LIMIT 1024 
#else 
	#define PALETTE_LIMIT 256 
#endif

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D map;
uniform vec2 mapDimension;
uniform int  useMap;
uniform int  type;

uniform float seed;

uniform vec2      contrast;
uniform int       contrastUseSurf;
uniform sampler2D contrastSurf;

uniform sampler2D conMap;
uniform int useConMap;

uniform vec2  dimension;
uniform vec2  scale;

uniform vec2  ditherSize;
uniform float dither[64];
uniform int   invert;

uniform int   colorMode;
uniform float steps;
uniform float rsteps;
uniform float gsteps;
uniform float bsteps;
uniform vec4  palette[PALETTE_LIMIT];
uniform int   keys;

float random  (in vec2 st, float seed) { return fract(sin(dot(st.xy, vec2(1892.9898, 78.23453))) * (seed + 437.54123)); }
vec2  random2 (in vec2 st, float seed) { float a = random(st, seed) * 6.28319; return vec2(cos(a), sin(a)); }

#region ============================== COLOR SPACES ==============================
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
	
	float colorDifferent(in vec4 c1, in vec4 c2) {
		vec3 lab1 = rgb2lab(c1.rgb);
		vec3 lab2 = rgb2lab(c2.rgb);
	
		return length(lab1 - lab2);
	}
#endregion

void main() {
	float con = contrast.x;
	if(contrastUseSurf == 1) {
		vec4 _vMap = texture2D( contrastSurf, v_vTexcoord );
		con = mix(contrast.x, contrast.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec2 dimScale = scale / dimension;
	vec2  pos = floor(v_vTexcoord / dimScale) * dimScale;
	vec4 _col = texture2D( gm_BaseTexture, pos );
	
	bool exactColor = false;
	vec4 col1, col2;
	
	if(colorMode == 0) {
		col1 = floor(_col * steps) / steps;
		col2 = ceil( _col * steps) / steps;
		
		col1.a = _col.a;
		col2.a = _col.a;
		
		exactColor = distance(_col, col1) < 0.05; 
		
	} else if(colorMode == 1) {
		int   closet1_index = 0;
		float closet1_value = 99.;
		
		int   closet2_index = 0;
		float closet2_value = 99.;
		
		for(int i = 0; i < keys; i++) {
			vec4 p_col = palette[i];
			float dif  = colorDifferent(p_col, _col);
			
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
		
		col1 = palette[closet1_index];
		col2 = palette[closet2_index];
		
	} else if(colorMode == 2) {
		col1.r = floor(_col.r * rsteps) / rsteps;
		col1.g = floor(_col.g * gsteps) / gsteps;
		col1.b = floor(_col.b * bsteps) / bsteps;
		
		col2.r = ceil( _col.r * rsteps) / rsteps;
		col2.g = ceil( _col.g * gsteps) / gsteps;
		col2.b = ceil( _col.b * bsteps) / bsteps;
		
		col1.a = _col.a;
		col2.a = _col.a;
		
		exactColor = distance(_col, col1) < 0.05; 
		
	} else if(colorMode == 3) {
		vec3 _hsv = rgb2hsv(_col.rgb);
		
		col1.r = floor(_hsv.r * rsteps) / rsteps;
		col1.g = floor(_hsv.g * gsteps) / gsteps;
		col1.b = floor(_hsv.b * bsteps) / bsteps;
		
		col2.r = ceil( _hsv.r * rsteps) / rsteps;
		col2.g = ceil( _hsv.g * gsteps) / gsteps;
		col2.b = ceil( _hsv.b * bsteps) / bsteps;
		
		col1.rgb = hsv2rgb(col1.rgb);
		col2.rgb = hsv2rgb(col2.rgb);
		
		col1.a = _col.a;
		col2.a = _col.a;
		
		exactColor = distance(_col, col1) < 0.05; 
		
	}
	
	if(exactColor) {
		gl_FragColor = _col;
		
	} else {
		float d1 = colorDifferent(_col, col1);
		float d2 = colorDifferent(_col, col2);
		float rat = d1 / (d1 + d2);
		
		if(useConMap == 0) {
			rat = (rat - 0.5) * con + 0.5;
			
		} else {
			vec4 con_map_data = texture2D( conMap, v_vTexcoord );
			float _cont = .1 + con * dot(con_map_data.rgb, vec3(0.2126, 0.7152, 0.0722));
			rat = (rat - 0.5) * _cont + 0.5;
		}
		
		vec2 px  = pos * dimension;
		     //px += random2(pos * dimension, seed) / dimension * .5;
		     px  = floor(px);
		
		if(useMap == 0) {
			float col = mod(px.x, ditherSize.x);
			float row = mod(px.y, ditherSize.y);
			
			float ditherVal = dither[int(row * ditherSize.x + col)] / (ditherSize.x * ditherSize.y - 1.);
			if(invert == 1) ditherVal = 1. - ditherVal;
			
			if(rat < ditherVal) gl_FragColor = col1;
			else                gl_FragColor = col2;	
				
		} else if(useMap == 1) {
			float col = mod(px.x, mapDimension.x);
			float row = mod(px.y, mapDimension.y);
			vec4 map_data = texture2D( map, vec2(col, row) / mapDimension );
			
			float ditherVal = dot(map_data.rgb, vec3(0.2126, 0.7152, 0.0722));
			if(invert == 1) ditherVal = 1. - ditherVal;
			
			if(rat < ditherVal) gl_FragColor = col1;
			else                gl_FragColor = col2;
				
		} else if(useMap == 2) {
			gl_FragColor = rat < random(v_vTexcoord, seed)? col1 : col2;
		}
	}
	
	gl_FragColor.a *= _col.a;
}
