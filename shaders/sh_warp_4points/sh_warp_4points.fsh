#pragma use(sampler)

#region -- sampler -- [1765244104.78094]
	uniform int  interpolation;
	uniform vec2 sampleDimension;
	uniform int  sampleMode;

    uniform sampler2D uvMap;
    uniform int   useUvMap;
    uniform float uvMapMix;

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
	    
	    // Use 3x3 grid where each sample combines adjacent weights via bilinear
	    for(int x = -1; x <= 1; x++)
	    for(int y = -1; y <= 1; y++) {
	        // Combine weights from 2 adjacent taps in each direction
	        float wx_a = lanczosWeight(float(x * 2 - 1) - offset.x, float(LANCZOS_RADIUS));
	        float wx_b = lanczosWeight(float(x * 2    ) - offset.x, float(LANCZOS_RADIUS));
	        float wy_a = lanczosWeight(float(y * 2 - 1) - offset.y, float(LANCZOS_RADIUS));
	        float wy_b = lanczosWeight(float(y * 2    ) - offset.y, float(LANCZOS_RADIUS));
	        
	        float wx_total = wx_a + wx_b;
	        float wy_total = wy_a + wy_b;
	        float w = wx_total * wy_total;
	        
	        // Offset for bilinear interpolation between the two taps
	        vec2 samplePos = vec2(x * 2, y * 2) - vec2(.5, .5) + vec2(wx_b / wx_total, wy_b / wy_total);
	        
	        col += w * texture2D(texture, center + samplePos * tx);
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
			return texture2Dintp(texture, pos);
		
			 if(sampleMode <= 1) return vec4(0.);
		else if(sampleMode == 2) return vec4(0.,0.,0., 1.);
		else if(sampleMode == 3) return texture2Dintp(texture, clamp(pos, 0., 1.));
		else if(sampleMode == 4) return texture2Dintp(texture, fract(pos));
		// 5
		else if(sampleMode == 6) { vec2 sp = vec2(fract(pos.x), pos.y); return (sp.y < 0. || sp.y > 1.) ? vec4(0.) : texture2Dintp(texture, sp); } 
		else if(sampleMode == 7) { vec2 sp = vec2(fract(pos.x), pos.y); return (sp.y < 0. || sp.y > 1.) ? vec4(0.,0.,0.,1.) : texture2Dintp(texture, sp); } 
		else if(sampleMode == 8) return texture2Dintp(texture, vec2(fract(pos.x), clamp(pos.y, 0., 1.)));
		// 9
		else if(sampleMode == 10) { vec2 sp = vec2(pos.x, fract(pos.y)); return (sp.x < 0. || sp.x > 1.) ? vec4(0.) : texture2Dintp(texture, sp); } 
		else if(sampleMode == 11) { vec2 sp = vec2(pos.x, fract(pos.y)); return (sp.x < 0. || sp.x > 1.) ? vec4(0.,0.,0.,1.) : texture2Dintp(texture, sp); } 
		else if(sampleMode == 12) return texture2Dintp(texture, vec2(clamp(pos.x, 0., 1.), fract(pos.y)));
		
		return vec4(0.);
	}
	vec4 sampleTexture( sampler2D texture, vec2 pos) { return sampleTexture(texture, pos, 0.); }
#endregion -- sampler --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D backSurface;
uniform vec2 p0;
uniform vec2 p1;
uniform vec2 p2;
uniform vec2 p3;
uniform vec2 dimension;
uniform int  tile;

float unmix( float st, float ed, float val) { return (val - st) / (ed - st); }

// 2 1
// 3 0

void main() {
	float px = v_vTexcoord.x;
	float py = v_vTexcoord.y;
	float u, v;
	vec2 uv, _p;
	
	vec2  tx = 1. / dimension;
	vec2 _p0 = p0;
	vec2 _p1 = p1;
	vec2 _p2 = p2;
	vec2 _p3 = p3;
	
	bool invX = p2.x > p1.x && p3.x > p0.x;
	bool invY = p3.y < p2.y && p0.y < p1.y;
	
	bool aliX = abs(p2.x - p3.x) < tx.x && abs(p1.x - p0.x) < tx.x;
	bool aliY = abs(p3.y - p0.y) < tx.y && abs(p2.y - p1.y) < tx.y; 
	
	#region linear interpolation
		if(aliX && aliY) {
			float tx = (px - p2.x) / (p1.x - p2.x);
			float ty = (py - p2.y) / (p3.y - p2.y);
				
			uv = vec2(tx, ty);
				
		} else if(aliX) { // trapezoid edge case
			float t = (px - p2.x) / (p1.x - p2.x);
		
			u = t;
			v = unmix(mix(p1.y, p2.y, 1. - t), mix(p0.y, p3.y, 1. - t), py);
	        uv = vec2(u, v);
	        
	    } else if (aliY) { // trapezoid edge case
	        float t = (py - p2.y) / (p3.y - p2.y);
		
			u = unmix(mix(p3.x, p2.x, 1. - t), mix(p0.x, p1.x, 1. - t), px);
			v = t;
	        uv = vec2(u, v);
	        
		} else {
	    	
	    	if(invX) {
	    		_p = _p2; _p2 = _p1; _p1 = _p;
	    		_p = _p3; _p3 = _p0; _p0 = _p;
	    	}
	    	
	    	if(invY) {
	    		_p = _p2; _p2 = _p3; _p3 = _p;
	    		_p = _p1; _p1 = _p0; _p0 = _p;
	    	}
	    	
			vec2 A = (_p3 - _p0) - (_p2 - _p1);
		    vec2 B = (_p0 - _p1);
		    vec2 C = (_p2 - _p1);
		    vec2 D =  _p1;
		
			float c1 = (B.y * C.x) + (A.y * D.x) - (B.x * C.y) - (A.x * D.y);
		    float c2 = (B.y * D.x) - (B.x * D.y);

			float _A = (A.y * C.x) - (A.x * C.y);
			float _B = (A.x * py) + c1 - (A.y * px);
			float _C = (B.x * py) + c2 - (B.y * px);

			u =  A == vec2(0.)?        0. : (-_B - sqrt(_B * _B - 4.0 * _A * _C)) / (_A * 2.0);
			v = (u * A.x + B.x) == 0.? 0. : (px - (u * C.x) - D.x) / (u * A.x + B.x);
			uv = vec2(1. - u, v);
			
			if(invX) uv.x = 1. - uv.x;
			if(invY) uv.y = 1. - uv.y;
		}
	#endregion
	
	if(tile == 1) uv = fract(1. + fract(uv));
	
	bool flip = (invX && !invY) || (!invX && invY);
	gl_FragColor = vec4(0.);
	
	if(uv.x >= 0. && uv.y >= 0. && uv.x <= 1. && uv.y <= 1.)
		gl_FragColor = flip? texture2Dintp( backSurface, uv ) : texture2Dintp( gm_BaseTexture, uv );
}