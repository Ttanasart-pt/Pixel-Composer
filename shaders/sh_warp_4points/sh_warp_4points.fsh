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

uniform vec2 dimension;
uniform vec2 surfaceSize;

uniform vec2 p0;
uniform vec2 p1;
uniform vec2 p2;
uniform vec2 p3;
uniform int  tile;
uniform int  flip;

float unmix( float st, float ed, float val) { return (val - st) / (ed - st); }

vec2 perspectiveUV(vec2 p, vec2 _p0, vec2 _p1, vec2 _p2, vec2 _p3) {
	vec2 A = (_p3 - _p0) - (_p2 - _p1);
    vec2 B = (_p0 - _p1);
    vec2 C = (_p2 - _p1);
    vec2 D =  _p1;

	float c1 = (B.y * C.x) + (A.y * D.x) - (B.x * C.y) - (A.x * D.y);
    float c2 = (B.y * D.x) - (B.x * D.y);

	float _A = (A.y * C.x) - (A.x * C.y);
	float _B = (A.x * p.y) + c1 - (A.y * p.x);
	float _C = (B.x * p.y) + c2 - (B.y * p.x);
	
	float u =  A == vec2(0.)?        0. : (-_B - sqrt(_B * _B - 4.0 * _A * _C)) / (_A * 2.0);
	float v = (u * A.x + B.x) == 0.? 0. : (p.x - (u * C.x) - D.x) / (u * A.x + B.x);
	
	return vec2(u, v);
}

// 2 1
// 3 0

void main() {
	float px = v_vTexcoord.x;
	float py = v_vTexcoord.y;
	float u, v;
	vec2 uv, _p;
	
	vec2 _p0 = p0 / surfaceSize;
	vec2 _p1 = p1 / surfaceSize;
	vec2 _p2 = p2 / surfaceSize;
	vec2 _p3 = p3 / surfaceSize;
	
	bool aliX = abs(p2.x - p3.x) < 1. && abs(p1.x - p0.x) < 1.;
	bool aliY = abs(p3.y - p0.y) < 1. && abs(p2.y - p1.y) < 1.;
	gl_FragColor = vec4(0.);
	
	#region linear interpolation
		if(aliX && aliY) {
			float tx = (px - _p2.x) / (_p1.x - _p2.x);
			float ty = (py - _p2.y) / (_p3.y - _p2.y);
				
			uv = vec2(tx, ty);
				
		} else if(aliX) { // trapezoid edge case
			float t  = (px - _p2.x) / (_p1.x - _p2.x);
			
			float y0 = mix(_p1.y, _p2.y, 1. - t);
			float y1 = mix(_p0.y, _p3.y, 1. - t);
			
			u = t;
			v = unmix(y0, y1, py);
	        uv = vec2(u, v);
	        
	        int side = y0 > y1? 1 : 0;
	        // if(flip != side) return;
	        if(side == 1) return;
	        
	    } else if (aliY) { // trapezoid edge case
	        float t = (py - _p2.y) / (_p3.y - _p2.y);
			
			float x0 = mix(_p3.x, _p2.x, 1. - t);
			float x1 = mix(_p0.x, _p1.x, 1. - t);
			
			u = unmix(x0, x1, px);
			v = t;
	        uv = vec2(u, v);
	        
	        int side = x0 > x1? 1 : 0;
	        if(flip != side) return;
	        
		} else {
			uv = perspectiveUV(v_vTexcoord, _p0, _p1, _p2, _p3);
			uv = 1. - uv;
		}
	#endregion
	
	if(tile == 1) uv = fract(1. + fract(uv));
	
	if(uv.x >= 0. && uv.y >= 0. && uv.x <= 1. && uv.y <= 1.)
		gl_FragColor = texture2Dintp( gm_BaseTexture, uv );
		
	// gl_FragColor = vec4(uv, 0., 1.);
}