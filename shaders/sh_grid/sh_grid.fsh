varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  position;
uniform vec2  dimension;
uniform float seed;
uniform int   shiftAxis;
uniform int   mode;
uniform int   aa;

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

float random (in vec2 st) { return fract(sin(dot(st.xy + vec2(85.456034, 64.54065), vec2(12.9898, 78.233))) * (43758.5453123 + seed) ); }

#region //////////////////////////////////// GRADIENT ////////////////////////////////////
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
	
	vec3 rgbMix(vec3 c1, vec3 c2, float t) { #region
		vec3 k1 = linearToGamma(c1);
		vec3 k2 = linearToGamma(c2);
		
		return gammaToLinear(mix(k1, k2, t));
	} #endregion 
	
	vec3 rgb2oklab(vec3 c) { #region
		const mat3 kCONEtoLMS = mat3(                
	         0.4121656120,  0.2118591070,  0.0883097947,
	         0.5362752080,  0.6807189584,  0.2818474174,
	         0.0514575653,  0.1074065790,  0.6302613616);
	    
		c = pow(c, vec3(2.2));
		c = pow( kCONEtoLMS * c, vec3(1.0 / 3.0) );
		
		return c;
	} #endregion
	
	vec3 oklab2rgb(vec3 c) { #region
		const mat3 kLMStoCONE = mat3(
	         4.0767245293, -1.2681437731, -0.0041119885,
	        -3.3072168827,  2.6093323231, -0.7034763098,
	         0.2307590544, -0.3411344290,  1.7068625689);
        
		c = kLMStoCONE * (c * c * c);
		c = pow(c, vec3(1. / 2.2));
		
	    return c;
	} #endregion

	vec3 oklabMax(vec3 c1, vec3 c2, float t) { #region
		vec3 k1 = rgb2oklab(c1);
		vec3 k2 = rgb2oklab(c2);
		
		return oklab2rgb(mix(k1, k2, t));
	} #endregion 
	
	vec3 rgb2hsv(vec3 c) { #region
		vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

	    float d = q.x - min(q.w, q.y);
	    float e = 0.0000000001;
	    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
	} #endregion

	vec3 hsv2rgb(vec3 c) { #region
	    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
	} #endregion

	float hueDist(float a0, float a1, float t) { #region
		float da = fract(a1 - a0);
	    float ds = fract(2. * da) - da;
	    return a0 + ds * t;
	} #endregion

	vec3 hsvMix(vec3 c1, vec3 c2, float t) { #region
		vec3 h1 = rgb2hsv(c1);
		vec3 h2 = rgb2hsv(c2);
	
		vec3 h = vec3(0.);
		h.x = h.x + hueDist(h1.x, h2.x, t);
		h.y = mix(h1.y, h2.y, t);
		h.z = mix(h1.z, h2.z, t);
	
		return hsv2rgb(h);
	} #endregion

	vec4 gradientEval(in float prog) { #region
		if(gradient_use_map == 1) {
			vec2 samplePos = mix(gradient_map_range.xy, gradient_map_range.zw, prog);
			return texture2D( gradient_map, samplePos );
		}
	
		vec4 col = vec4(0.);
	
		for(int i = 0; i < GRADIENT_LIMIT; i++) {
			if(gradient_time[i] == prog) {
				col = gradient_color[i];
				break;
			} else if(gradient_time[i] > prog) {
				if(i == 0) 
					col = gradient_color[i];
				else {
					float t  = (prog - gradient_time[i - 1]) / (gradient_time[i] - gradient_time[i - 1]);
					vec3  c0 = gradient_color[i - 1].rgb;
					vec3  c1 = gradient_color[i].rgb;
					float a  = mix(gradient_color[i - 1].a, gradient_color[i].a, t);
					
					if(gradient_blend == 0)
						col = vec4(mix(c0, c1, t), a);
						
					else if(gradient_blend == 1)
						col = gradient_color[i - 1];
						
					else if(gradient_blend == 2)
						col = vec4(hsvMix(c0, c1, t), a);
						
					else if(gradient_blend == 3)
						col = vec4(oklabMax(c0, c1, t), a);
					
					else if(gradient_blend == 4)
						col = vec4(rgbMix(c0, c1, t), a);
				}
				break;
			}
			if(i >= gradient_keys - 1) {
				col = gradient_color[gradient_keys - 1];
				break;
			}
		}
	
		return col;
	} #endregion
	
#endregion //////////////////////////////////// GRADIENT ////////////////////////////////////

void main() {
	#region params
		vec2 sca = scale;
		if(scaleUseSurf == 1) {
			vec4 _vMap = texture2D( scaleSurf, v_vTexcoord );
			sca = vec2(mix(scale.x, scale.y, (_vMap.r + _vMap.g + _vMap.b) / 3.));
		}
		
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
	
	vec2 ntx = v_vTexcoord * vec2(1., dimension.y / dimension.x);
	
	if(mode == 1) {
		vec2 px = floor((ntx - position) * dimension);
		
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
	
	vec2 pos = ntx - position, _pos;
	float ratio = dimension.x / dimension.y;
	_pos.x = pos.x * ratio * cos(ang) - pos.y * sin(ang);
	_pos.y = pos.x * ratio * sin(ang) + pos.y * cos(ang);
	
	if(shiftAxis == 0) {
		shf /= sca.x;
		
		float cellY  = floor(_pos.y * sca.y);
		float _sec   = mod(cellY, 2.);
		float shiftX = _sec * shf;
		
		_pos.x += shiftX + _sec * secShift;
		 sca.x *= 1.     + _sec * secScale;
	} else {
		shf /= sca.y;
		
		float cellX  = floor(_pos.x * sca.x);
		float _sec   = mod(cellX, 2.);
		float shiftY = _sec * shf;
	
		_pos.y += shiftY + _sec * secShift;
		 sca.y *= 1.     + _sec * secScale;
	}
	
	vec2 sqSt  = floor(_pos * sca) / sca;
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
		colr = gradientEval(random(sqSt));
		
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
		
		colr = texture2D( gm_BaseTexture, uv );
		
	} else if(mode == 4) {
		vec2 uv = fract(sqSt);
		colr = texture2D( gm_BaseTexture, uv );
	}
	
	float _aa = 4. / max(dimension.x, dimension.y);
	gl_FragColor = mix(gapCol, colr, aa == 1? smoothstep(wid - _aa, wid, dist) : step(wid, dist));
}
