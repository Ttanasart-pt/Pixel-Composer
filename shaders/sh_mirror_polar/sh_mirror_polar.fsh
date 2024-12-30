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

#define TAU 6.283185307179586
#define PI  3.141592653589793

uniform vec2  dimension;
uniform vec2  position;
uniform vec2  scale;
uniform float angle;
uniform float spokes;
uniform int   reflecc;
uniform int   rscale;

float round(in float a) { return floor(a + .5);  }

void main() {
	vec2  ps = v_vTexcoord;
	vec2  px = v_vTexcoord * dimension - position;
	float _angle;
	float a = TAU / spokes;
	if(reflecc == 1) a *= 2.;
	
	_angle = atan(px.y, px.x) + angle;
	_angle = TAU - mod(_angle, TAU); 
	_angle = mod(_angle, a);
	
	if(reflecc == 1 && _angle > a / 2.) _angle = a - _angle;
	
	float dist = length(px);
		 if(rscale == 0) dist = dist * scale.y;
	else if(rscale == 1) dist = pow(dist, scale.y);
	
	float _alpha = (angle + PI) - (_angle + angle);
	float iangle = (angle + PI) + _alpha * scale.x;
	
	ps = (position + vec2(cos(iangle) * dist, -sin(iangle) * dist )) / dimension;
	ps = fract(ps);
	
	if(mod(floor(ps.x), 2.) > 1.) ps.x = 1. - ps.x;
	if(mod(floor(ps.y), 2.) > 1.) ps.y = 1. - ps.y;
	
	gl_FragColor = sampleTexture( gm_BaseTexture, ps );
}
