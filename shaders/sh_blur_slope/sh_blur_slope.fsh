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

#define MAX_STRENGTH 64.

varying vec2  v_vTexcoord;
varying vec4  v_vColour;

uniform vec2      dimension;
uniform sampler2D slopeMap;
uniform vec2      slopeMapDim;
uniform float	  stepSize;

uniform vec2      strength;
uniform int       strengthUseSurf;
uniform sampler2D strengthSurf;

uniform int	gamma;

vec2 tx;
vec2 txMap;

float sampleBright(vec2 pos) { vec4 c = sampleTexture(slopeMap, pos); return (c.r + c.g + c.b) / 3.;  }

vec2 sampleSlope(vec2 pos) { #region 
	float h0 = sampleBright(clamp(pos + vec2(-txMap.x, 0.), 0., 1.));
	float h1 = sampleBright(clamp(pos + vec2( txMap.x, 0.), 0., 1.));
	float h2 = sampleBright(clamp(pos + vec2(0., -txMap.y), 0., 1.));
	float h3 = sampleBright(clamp(pos + vec2(0.,  txMap.y), 0., 1.));
	
	return vec2(h1 - h0, h3 - h2);
} #endregion

void main() {
	float str = strength.x;
	if(strengthUseSurf == 1) {
		vec4 _vMap = texture2D( strengthSurf, v_vTexcoord );
		str = mix(strength.x, strength.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	tx    = 1. / dimension;
	txMap = 1. / slopeMapDim;
	
	float alpha = 0.;
	vec4  colr  = vec4(0.);
	vec2  pos   = v_vTexcoord;
	
	for(float i = 0.; i < MAX_STRENGTH; i++) {
		if(i > str) break;
		
		float str = 1. - (i / str);
		vec4  c = sampleTexture(gm_BaseTexture, pos);
		if(gamma == 1) c.rgb = pow(c.rgb, vec3(2.2));
		
		colr  += c * str;
		alpha += str;
		
		vec2 slp = sampleSlope(pos);
		pos += slp * stepSize;
	}
	
    vec4 res = colr / alpha;
    if(gamma == 1) res.rgb = pow(res.rgb, vec3(1. / 2.2));
    
    gl_FragColor = res;
}