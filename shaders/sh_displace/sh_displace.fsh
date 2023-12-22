//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D map;
uniform vec2  dimension;
uniform vec2  map_dimension;
uniform vec2  displace;
uniform float strength;
uniform float middle;
uniform int   iterate;
uniform int   use_rg;
uniform int   sampleMode;
uniform int   blendMode;

uniform sampler2D strengthSurf;
uniform int strengthUseSurf;

float bright(in vec4 col) { return dot(col.rgb, vec3(0.2126, 0.7152, 0.0722)) * col.a; }

#region /////////////// SAMPLING ///////////////

	const float PI = 3.14159265358979323846;
	uniform int interpolation;
	uniform vec2 sampleDimension;

	const int RSIN_RADIUS = 1;

	float sinc ( float x ) { return x == 0.? 1. : sin(x * PI) / (x * PI); }

	vec4 texture2D_rsin( sampler2D texture, vec2 uv ) {
	    vec2 tx = 1.0 / sampleDimension;
	    vec2 p  = uv * sampleDimension - vec2(0.5);
    
		vec4 sum = vec4(0.0);
	    float weights = 0.;
    
	    for (int x = -RSIN_RADIUS; x <= RSIN_RADIUS; x++)
		for (int y = -RSIN_RADIUS; y <= RSIN_RADIUS; y++) {
	        float a = length(vec2(float(x), float(y))) / float(RSIN_RADIUS);
			if(a > 1.) continue;
	        float w = sinc(a * PI * tx.x) * sinc(a * PI * tx.y);
	        vec2 offset = vec2(float(x), float(y)) * tx;
	        vec4 sample = texture2D(texture, (p + offset + vec2(0.5)) / sampleDimension);
	        sum += w * sample;
	        weights += w;
	    }
	
	    return sum / weights;
	}

	vec4 texture2D_bicubic( sampler2D texture, vec2 uv ) {
		uv = uv * sampleDimension + 0.5;
		vec2 iuv = floor( uv );
		vec2 fuv = fract( uv );
		uv = iuv + fuv * fuv * (3.0 - 2.0 * fuv);
		uv = (uv - 0.5) / sampleDimension;
		return texture2D( texture, uv );
	}

	vec4 texture2Dintp( sampler2D texture, vec2 uv ) {
		if(interpolation == 2)		return texture2D_bicubic( texture, uv );
		else if(interpolation == 3)	return texture2D_rsin( texture, uv );
		return texture2D( texture, uv );
	}

	vec4 sampleTexture(vec2 pos) {
		if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
			return texture2Dintp(gm_BaseTexture, pos);
	
		if(sampleMode == 0) 
			return vec4(0.);
		if(sampleMode == 1) 
			return texture2Dintp(gm_BaseTexture, clamp(pos, 0., 1.));
		if(sampleMode == 2) 
			return texture2Dintp(gm_BaseTexture, fract(pos));
	
		return vec4(0.);
	}

#endregion /////////////// SAMPLING ///////////////

vec2 shiftMap(in vec2 pos, in float str) { #region
	vec4  disP = texture2Dintp( map, pos );
	vec2  sam_pos;
	vec2  raw_displace = displace / dimension;
	float _str;
	
	if(strengthUseSurf == 1) {
		vec4 strMap = texture2Dintp( strengthSurf, pos );
		str *= (strMap.r + strMap.g + strMap.b) / 3.;
	}
	
	if(use_rg == 1) {
		vec2 _disp = vec2(disP.r - middle, disP.g - middle) * vec2((disP.r + disP.g + disP.b) / 3. - middle) * str;
		
		sam_pos = pos + _disp;
	} else if(use_rg == 2) {
		float _ang = disP.r * PI * 2.;
		_str = (disP.g - middle) * str;
		
		sam_pos = pos + _str * vec2(cos(_ang), sin(_ang));
	} else {
		_str = (bright(disP) - middle) * str;
		
		sam_pos = pos + _str * raw_displace;
	}
	
	return sam_pos;
} #endregion

vec4 blend(in vec4 c0, in vec4 c1) { #region
	       if(blendMode == 0) return c1;
	  else if(blendMode == 1) {
		float b0 = bright(c0);
		float b1 = bright(c1);
		return b0 < b1? c0 : c1;
	} else if(blendMode == 2) {
		float b0 = bright(c0);
		float b1 = bright(c1);
		return b0 > b1? c0 : c1;
	}
	
	return c1;
} #endregion

void main() { #region
	vec2 samPos = v_vTexcoord;
	vec4 ccol   = sampleTexture( v_vTexcoord ), ncol;
	
	if(iterate == 1) {
		for(float i = 0.; i < strength; i++) {
			samPos = shiftMap(samPos, 1.);
			ncol   = blend(ccol, sampleTexture( samPos ));
		}
	} else {
		samPos = shiftMap(samPos, strength);
		ncol   = sampleTexture( samPos );
	}
	
    gl_FragColor = blend(ccol, ncol);
} #endregion