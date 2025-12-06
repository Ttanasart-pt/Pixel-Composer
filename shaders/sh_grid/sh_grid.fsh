#pragma use(gradient)

#region -- gradient -- [1764901316.7213297]
	#define GRADIENT_LIMIT 128
	
	uniform int		  gradient_blend;
	uniform vec4	  gradient_color[GRADIENT_LIMIT];
	uniform float	  gradient_time[GRADIENT_LIMIT];
	uniform int		  gradient_keys;
	uniform int       gradient_use_map;
	uniform vec4      gradient_map_range;
	uniform sampler2D gradient_map;

	vec3 linearToGamma(vec3 c) { return pow(c, vec3(     2.2)); }
	vec3 gammaToLinear(vec3 c) { return pow(c, vec3(1. / 2.2)); }
	
	vec3 rgbMix(vec3 c1, vec3 c2, float t) {
		vec3 k1 = linearToGamma(c1);
		vec3 k2 = linearToGamma(c2);
		
		return gammaToLinear(mix(k1, k2, t));
	} 
	
	vec3 rgb2oklab(vec3 c) {
		const mat3 kCONEtoLMS = mat3(                
	         0.4121656120,  0.2118591070,  0.0883097947,
	         0.5362752080,  0.6807189584,  0.2818474174,
	         0.0514575653,  0.1074065790,  0.6302613616);
	    
		c = pow(c, vec3(2.2));
		c = pow( kCONEtoLMS * c, vec3(1.0 / 3.0) );
		
		return c;
	}
	
	vec3 oklab2rgb(vec3 c) {
		const mat3 kLMStoCONE = mat3(
	         4.0767245293, -1.2681437731, -0.0041119885,
	        -3.3072168827,  2.6093323231, -0.7034763098,
	         0.2307590544, -0.3411344290,  1.7068625689);
        
		c = kLMStoCONE * (c * c * c);
		c = pow(c, vec3(1. / 2.2));
		
	    return c;
	}

	vec3 oklabMax(vec3 c1, vec3 c2, float t) {
		vec3 k1 = rgb2oklab(c1);
		vec3 k2 = rgb2oklab(c2);
		
		return oklab2rgb(mix(k1, k2, t));
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

	float hueDist(float a0, float a1, float t) {
		float da = fract(a1 - a0);
	    float ds = fract(2. * da) - da;
	    return a0 + ds * t;
	}

	vec3 hsvMix(vec3 c1, vec3 c2, float t) {
		vec3 h1 = rgb2hsv(c1);
		vec3 h2 = rgb2hsv(c2);
	
		vec3 h = vec3(0.);
		h.x = h.x + hueDist(h1.x, h2.x, t);
		h.y = mix(h1.y, h2.y, t);
		h.z = mix(h1.z, h2.z, t);
	
		return hsv2rgb(h);
	}

	vec4 gradientEval(in float prog) {
		if(gradient_use_map == 1) {
			vec2 samplePos = mix(gradient_map_range.xy, gradient_map_range.zw, prog);
			return texture2D( gradient_map, samplePos );
		}
		
		for(int i = 0; i < GRADIENT_LIMIT; i++) {
			if(gradient_time[i] == prog) {
				return gradient_color[i];
				
			} else if(gradient_time[i] > prog) {
				if(i == 0) 
					return gradient_color[i];
				else {
					float t  = (prog - gradient_time[i - 1]) / (gradient_time[i] - gradient_time[i - 1]);
					vec3  c0 = gradient_color[i - 1].rgb;
					vec3  c1 = gradient_color[i].rgb;
					float a  = mix(gradient_color[i - 1].a, gradient_color[i].a, t);
					
					if(gradient_blend == 0)
						return vec4(mix(c0, c1, t), a);
						
					else if(gradient_blend == 1)
						return gradient_color[i - 1];
						
					else if(gradient_blend == 2)
						return vec4(hsvMix(c0, c1, t), a);
						
					else if(gradient_blend == 3)
						return vec4(oklabMax(c0, c1, t), a);
					
					else if(gradient_blend == 4)
						return vec4(rgbMix(c0, c1, t), a);
				}
				break;
			}
			
			if(i >= gradient_keys - 1)
				return gradient_color[gradient_keys - 1];
		}
	
		return gradient_color[gradient_keys - 1];
	}
	
#endregion -- gradient --
#pragma use(sampler_simple)

#region -- sampler_simple -- [1764837291.6127295]
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
        else if(sampleMode == 2) return texture2D(texture, clamp(pos, 0., 1.));
        else if(sampleMode == 3) return texture2D(texture, fract(pos));
        else if(sampleMode == 4) return vec4(vec3(0.), 1.);
        
        return vec4(0.);
    }
    vec4 sampleTexture( sampler2D texture, vec2 pos) { return sampleTexture(texture, pos, 0.); }
#endregion -- sampler_simple --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  position;
uniform vec2  dimension;
uniform float seed;
uniform int   shiftAxis;
uniform int   mode;
uniform int   aa;

uniform int       scaleMode;
uniform vec2      scale;
uniform int       scaleUseSurf;
uniform sampler2D scaleSurf;

uniform vec2      angle;
uniform int       angleUseSurf;
uniform sampler2D angleSurf;

uniform vec2      width;
uniform int       widthUseSurf;
uniform sampler2D widthSurf;

uniform vec2      shift;
uniform int       shiftUseSurf;
uniform sampler2D shiftSurf;

uniform float secScale;
uniform float secShift;
uniform float gapAcc;
uniform vec4  gapCol;
uniform int   gradient_use;
uniform vec2  level;

uniform int   diagonal;
uniform int   uniformSize;

uniform int   textureTruchet;
uniform float truchetSeed;
uniform float truchetThresX;
uniform float truchetThresY;
uniform vec2  truchetAngle;

uniform float randShift;
uniform float randShiftSeed;
uniform float randScale;
uniform float randScaleSeed;

float random (in vec2 st) { return fract(sin(dot(st.xy + vec2(85.456034, 64.54065), vec2(12.9898, 78.233))) * (43758.5453123 + seed) ); }

void main() {
	#region params
		vec2 sca = scale;
		if(scaleUseSurf == 1) {
			vec4 _vMap = texture2D( scaleSurf, v_vTexcoord );
			sca = vec2(mix(scale.x, scale.y, (_vMap.r + _vMap.g + _vMap.b) / 3.));
		}
		if(scaleMode == 1) sca = dimension / sca;
		
		float ang = angle.x;
		if(angleUseSurf == 1) {
			vec4 _vMap = texture2D( angleSurf, v_vTexcoord );
			ang = mix(angle.x, angle.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		ang = radians(ang);
		
		float wid = width.x;
		if(widthUseSurf == 1) {
			vec4 _vMap = texture2D( widthSurf, v_vTexcoord );
			wid = mix(width.x, width.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float shf = shift.x;
		if(shiftUseSurf == 1) {
			vec4 _vMap = texture2D( shiftSurf, v_vTexcoord );
			shf = mix(shift.x, shift.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
	#endregion
	
	vec2 ntx = useUvMap == 0? v_vTexcoord : mix(v_vTexcoord, texture2D( uvMap, v_vTexcoord ).xy, uvMapMix);
	vec2 asp = vec2(dimension.x / dimension.y, 1.);
	
	sca *= asp;
	ntx *= asp;
	
	if(mode == 1) {
		vec2 px = floor((ntx - position * asp) * dimension);
		
		sca = floor(sca);
		vec2 scaG = sca - (gapAcc + 1.);
		
		if(diagonal == 0) {
			vec2 fl  = floor(px / sca) * sca;
			vec2 fr  = px - fl;
		
			if(fr.x > scaG.x || fr.y > scaG.y)
				gl_FragColor = gapCol;
				
			else 
				gl_FragColor = gradientEval(random(fl));
				
		} else if(diagonal == 1) {
			float _x =  px.x + px.y;
			float _y = -px.x + px.y;
			
			float mx = mod(_x, sca.x);
			float my = mod(_y, sca.y);
			
			if(mx > scaG.x || my > scaG.y)
				gl_FragColor = gapCol;
				
			else 
				gl_FragColor = gradientEval(random(vec2(_x, _y) - vec2(mx, my)));
				
		}
		return;
	}
	
	sca = dimension / sca;
	
	vec2  pos = ntx - position * asp, _pos;
	
	_pos.x = pos.x * cos(ang) - pos.y * sin(ang);
	_pos.y = pos.x * sin(ang) + pos.y * cos(ang);
	
	shf /= sca[shiftAxis];
	int antiAxis = shiftAxis == 0? 1 : 0;
	
	float cell  = floor(_pos[antiAxis] * sca[antiAxis]);
	float _sec  = mod(cell, 2.);
	float _shft = (_sec * secShift) + (cell * shf);
	float _rdsh = randShift * (random(randShiftSeed / 1000. + vec2(cell / dimension.x)) * 2. - 1.);
	_shft += _rdsh;
	
	float _scas = (_sec * secScale) + (1.);
	float _rdsc = randScale * (random(randScaleSeed / 1000. + vec2(cell / dimension.x)) * 2. - 1.);
	_scas += _rdsc;
	
		 if(shiftAxis == 0) { _pos.x += _shft; sca.x *= _scas; } 
	else if(shiftAxis == 1) { _pos.y += _shft; sca.y *= _scas; }
		 
	vec2 sqSt  = floor(_pos * sca) / sca;
	vec2 sqStW = fract(fract(sqSt) + 1.);
	
	vec2 _dist = _pos - sqSt;
	vec2 nPos  = abs(_dist * sca - vec2(0.5)) * 2.; //distance in x, y axis
	float rat  = uniformSize == 1? sca.y / sca.x : 1.;
	float dist = 1. - max((nPos.x - 1.) * rat + 1., nPos.y);
	
	vec4 colr;
	
	if(mode == 2) {
		dist = (dist - level.x) / (level.y - level.x);
		gl_FragColor = vec4(vec3(dist), 1.);
		return;
	}
	
	if(mode == 0) {
		colr = gradientEval(random(sqStW));
		
	} else if(mode == 3) {
		vec2 uv = fract(_pos * sca);
		
		if(textureTruchet == 1) {
			float rx = random(floor(_pos * sca) + truchetSeed / 100.);
			float ry = random(floor(_pos * sca) + truchetSeed / 100. + vec2(0.4864, 0.6879));
			
			if(rx >= truchetThresX) uv.x = 1. - uv.x;
			if(ry >= truchetThresY) uv.y = 1. - uv.y;
			
			float ang = radians(truchetAngle.x + (truchetAngle.y - truchetAngle.x) * random(floor(_pos * sca) + truchetSeed / 100. + vec2(0.9843, 0.1636)));
			uv = 0.5 + mat2(cos(ang), -sin(ang), sin(ang), cos(ang)) * (uv - 0.5);
		}
		
		colr = sampleTexture( gm_BaseTexture, uv );
		
	} else if(mode == 4) {
		vec2 uv = fract(sqSt);
		colr = sampleTexture( gm_BaseTexture, uv );
	}
	
	float _aa = 4. / max(dimension.x, dimension.y);
	gl_FragColor = mix(gapCol, colr, aa == 1? smoothstep(wid - _aa, wid, dist) : step(wid, dist));
}
