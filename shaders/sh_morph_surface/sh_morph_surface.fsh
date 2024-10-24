#pragma use(sampler)

#region -- sampler -- [1729740697.9444373]
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
			 if(interpolation <= 1)	return texture2D(          texture, uv );
		else if(interpolation == 2)	return texture2D_bicubic(  texture, uv );
		else if(interpolation == 3)	return texture2D_lanczos3( texture, uv );
		
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

uniform sampler2D sFrom;
uniform sampler2D sTo;
uniform vec2 dimension;
uniform float amount;
uniform float threshold;

#define TAU 6.283185307179586

void main() {
	gl_FragColor = vec4(0.);
	
	//if(amount == 0.) {
	//	gl_FragColor = texture2Dintp( sFrom, v_vTexcoord );
	//	return;
	//} else if(amount == 1.) {
	//	gl_FragColor = texture2Dintp( sTo, v_vTexcoord );
	//	return;
	//} 
	
	vec2 pxFrom, pxTo;
	vec4 from, to;
	float dist;
	
	for(float i = 0.; i <= dimension.x; i++) {
		float base = 1.;
		float top  = 0.;
		
		if(amount > 0.5)
			dist = i / dimension.x * (1. / amount);
		else 
			dist = i / dimension.x * (1. / (1. - amount));
		
		for(float j = 0.; j <= 64.; j++) {
			float ang = top / base * TAU;
			if(amount > 0.5) ang = TAU - ang;
			
			top += 2.;
			if(top >= base) {
				top = 1.;
				base *= 2.;
			}
			
			pxFrom = (vec2(cos(ang), sin(ang)) * i) / dimension;
			vec2 xFrom = v_vTexcoord + pxFrom;
			if(xFrom.x < 0. || xFrom.y < 0. || xFrom.x > 1. || xFrom.y > 1.) continue;
			
			vec2 vF = i == 0.? vec2(0.) : normalize(pxFrom);
			
			if(amount > 0.5) {
				from = texture2Dintp( sFrom, xFrom );
				if(from.a == 0.) continue;
				
				pxTo = xFrom - (vF * dist);
				if(pxTo.x < 0. || pxTo.y < 0. || pxTo.x > 1. || pxTo.y > 1.) continue;
				
				to = texture2Dintp( sTo, pxTo );
				if(to.a == 0.) continue;
			} else {
				to = texture2Dintp( sTo, xFrom );
				if(to.a == 0.) continue;
				
				pxTo = xFrom - (vF * dist);
				if(pxTo.x < 0. || pxTo.y < 0. || pxTo.x > 1. || pxTo.y > 1.) continue;
				
				from = texture2Dintp( sFrom, pxTo );
				if(from.a == 0.) continue;
			}
			
			if(distance(from, to) <= threshold * 2.) {
				gl_FragColor = mix(from, to, amount);
				return;
			}
		}
	}
}
