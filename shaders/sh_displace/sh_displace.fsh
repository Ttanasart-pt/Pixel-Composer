#pragma use(sampler)

#region -- sampler -- [1730686036.7372286]
	uniform int  interpolation;
	uniform vec2 sampleDimension;
	uniform int  sampleMode;

	const float PI = 3.14159265358979323846;
	float sinc ( float x ) { return x == 0.? 1. : sin(x * PI) / (x * PI); }

	vec4 texture2D_bicubic( sampler2D texture, vec2 uv ) {
		uv = uv * sampleDimension + 0.5;
		vec2 iuv = floor( uv );
		vec2 fuv = fract( uv );
		uv = iuv + fuv * fuv * (3.0 - 2.0 * fuv);
		uv = (uv - 0.5) / sampleDimension;
		return texture2D( texture, uv );
	}

	const int RSIN_RADIUS = 1;
	vec4 texture2D_rsin( sampler2D texture, vec2 uv ) {
		vec2 tx = 1.0 / sampleDimension;
		vec2 p  = uv * sampleDimension;
		
		vec4  col = vec4(0.);
		float wei = 0.;
		
		for (int x = -RSIN_RADIUS; x <= RSIN_RADIUS; x++)
		for (int y = -RSIN_RADIUS; y <= RSIN_RADIUS; y++) {
			vec2 sx = vec2(float(x), float(y));
			float a = length(sx) / float(RSIN_RADIUS);
			// if(a > 1.) continue;
			
			vec4 sample = texture2D(texture, uv + sx * tx);
			float w     = sinc(a * PI * tx.x) * sinc(a * PI * tx.y);
			
			col += w * sample;
			wei += w;
		}
		
		col /= wei;
		return col;
	}

	const int LANCZOS_RADIUS = 3;
	float lanczosWeight(float d, float n) { return d == 0.0 ? 1.0 : (d * d < n * n ? sinc(d) * sinc(d / n) : 0.0); }

	vec4 texture2D_lanczos3( sampler2D texture, vec2 uv ) {
		vec2 center = uv - (mod(uv * sampleDimension, 1.0) - 0.5) / sampleDimension;
		vec2 offset = (uv - center) * sampleDimension;
		vec2 tx = 1. / sampleDimension;
		
		vec4  col = vec4(0.);
		float wei = 0.;
		
		for(int x = -LANCZOS_RADIUS; x < LANCZOS_RADIUS; x++)
		for(int y = -LANCZOS_RADIUS; y < LANCZOS_RADIUS; y++) {
			
			float wx = lanczosWeight(float(x) - offset.x, float(LANCZOS_RADIUS));
			float wy = lanczosWeight(float(y) - offset.y, float(LANCZOS_RADIUS));
			float w  = wx * wy;
			
			col += w * texture2D(texture, center + vec2(x, y) * tx);
			wei += w;
		}
		
		col /= wei;
		return col;
	}

	vec4 texture2Dintp( sampler2D texture, vec2 uv ) {
			 if(interpolation <= 2)	return texture2D(          texture, uv );
		else if(interpolation == 3)	return texture2D_bicubic(  texture, uv );
		else if(interpolation == 4)	return texture2D_lanczos3( texture, uv );
		
		return texture2D( texture, uv );
	}

	vec4 sampleTexture( sampler2D texture, vec2 pos) {
		if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
			return texture2Dintp(texture, pos);
		
			 if(sampleMode <= 1) return vec4(0.);
		else if(sampleMode == 2) return texture2Dintp(texture, clamp(pos, 0., 1.));
		else if(sampleMode == 3) return texture2Dintp(texture, fract(pos));
		else if(sampleMode == 4) return vec4(vec3(0.), 1.);
		
		return vec4(0.);
	}
#endregion -- sampler --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D map;
uniform sampler2D map2;

uniform vec2  dimension;
uniform vec2  map_dimension;
uniform vec2  displace;
uniform float middle;
uniform int   mode;
uniform int   sepAxis;

uniform int   iterate;
uniform float iteration;
uniform int   blendMode;
uniform int   fadeDist;
uniform int   reposition;

uniform vec2      strength;
uniform int       strengthUseSurf;
uniform sampler2D strengthSurf;

float bright(in vec4 col) { return dot(col.rgb, vec3(0.2126, 0.7152, 0.0722)) * col.a; }

vec2 shiftMap(in vec2 pos, in float str) {
	vec2  tx   = 1. / dimension;
	vec4  disP = texture2Dintp( map, pos );
	vec2  raw_displace = displace * tx;
	
	vec2  sam_pos;
	float _str;
	vec2  _disp;
	
	if(mode == 0) {
		_str  = (bright(disP) - middle) * str;
		_disp = _str * raw_displace;
		
		sam_pos = pos + _disp;
		
	} else if(mode == 1) {
		if(sepAxis == 0)
			_disp = vec2(disP.r - middle, disP.g - middle) * vec2((disP.r + disP.g + disP.b) / 3. - middle) * str;
		else if(sepAxis == 1) {
			vec4  disP2 = texture2Dintp( map2, pos );
			
			_disp.x = (bright(disP)  - middle) * str;
			_disp.y = (bright(disP2) - middle) * str;
		}
		
		sam_pos = pos + _disp;
		
	} else if(mode == 2) {
		float _ang;
		
		if(sepAxis == 0) {
			_ang = disP.r * PI * 2.;
			_str = (disP.g - middle) * str;
		} else if(sepAxis == 1) {
			vec4  disP2 = texture2Dintp( map2, pos );
			
			_ang = bright(disP) * PI * 2.;
			_str = (bright(disP2) - middle) * str;
		}
		
		sam_pos = pos + _str * vec2(cos(_ang), sin(_ang));
		
	} else if(mode == 3) {
		vec4  d0 = texture2Dintp( map, pos + vec2( tx.x, 0.) ); float h0 = (d0.r + d0.g + d0.b) / 3.;
		vec4  d1 = texture2Dintp( map, pos - vec2( 0., tx.y) ); float h1 = (d1.r + d1.g + d1.b) / 3.;
		vec4  d2 = texture2Dintp( map, pos - vec2( tx.x, 0.) ); float h2 = (d2.r + d2.g + d2.b) / 3.;
		vec4  d3 = texture2Dintp( map, pos + vec2( 0., tx.y) ); float h3 = (d3.r + d3.g + d3.b) / 3.;
		
		vec2 grad = vec2( h0 - h2, h3 - h1 ) - middle;
		sam_pos = pos + grad * str;
	}
	
	return sam_pos;
}

vec4 blend(in vec4 c0, in vec4 c1) {
	if(blendMode == 0) return c1;
	
	if(blendMode == 1) {
		float b0 = bright(c0);
		float b1 = bright(c1);
		return b0 < b1? c0 : c1;
	} 
	
	if(blendMode == 2) {
		float b0 = bright(c0);
		float b1 = bright(c1);
		return b0 > b1? c0 : c1;
	}
	
	return c1;
}

void main() {
	vec2 samPos = v_vTexcoord;
	vec4 ccol = sampleTexture( gm_BaseTexture, v_vTexcoord );
	vec4 ncol = ccol;
	
	float stren = strength.x;
	float stMax = strength.x;
	if(strengthUseSurf == 1) {
		vec4 strMap = texture2Dintp( strengthSurf, v_vTexcoord );
		stren = mix(strength.x, strength.y, (strMap.r + strMap.g + strMap.b) / 3.);
		stMax = strength.y;
	}
	
	if(iterate == 1) {
		float _t = 1. / (iteration - 1.);
		float str;
		vec4  c;
		
		if(reposition == 1) stren /= iteration;
		
		for(float i = 0.; i < iteration; i++) {
			str    = stren * (i * _t);
			samPos = shiftMap(reposition == 1? samPos : v_vTexcoord, str);
			c      = sampleTexture( gm_BaseTexture, samPos );
			if(fadeDist == 1) c.rgb *= 1. - i * _t;
			
			ncol   = blend(ncol, c);
		}
	} else {
		samPos = shiftMap(samPos, stren);
		ncol   = sampleTexture( gm_BaseTexture, samPos );
	}
	
    gl_FragColor = blend(ccol, ncol);
}