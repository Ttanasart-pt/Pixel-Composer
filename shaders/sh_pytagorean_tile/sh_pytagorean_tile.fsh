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

#region -- sampler_simple -- [1765194569.6586206]
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
		else if(sampleMode == 2) return vec4(0.,0.,0., 1.);
		else if(sampleMode == 3) return texture2D(texture, clamp(pos, 0., 1.));
		else if(sampleMode == 4) return texture2D(texture, fract(pos));
        // 5
		else if(sampleMode == 6) { vec2 sp = vec2(fract(pos.x), pos.y); return (sp.y < 0. || sp.y > 1.) ? vec4(0.) : texture2D(texture, sp); } 
		else if(sampleMode == 7) { vec2 sp = vec2(fract(pos.x), pos.y); return (sp.y < 0. || sp.y > 1.) ? vec4(0.,0.,0.,1.) : texture2D(texture, sp); } 
		else if(sampleMode == 8) return texture2D(texture, vec2(fract(pos.x), clamp(pos.y, 0., 1.)));
		// 9
		else if(sampleMode == 10) { vec2 sp = vec2(pos.x, fract(pos.y)); return (sp.x < 0. || sp.x > 1.) ? vec4(0.) : texture2D(texture, sp); } 
		else if(sampleMode == 11) { vec2 sp = vec2(pos.x, fract(pos.y)); return (sp.x < 0. || sp.x > 1.) ? vec4(0.,0.,0.,1.) : texture2D(texture, sp); } 
		else if(sampleMode == 12) return texture2D(texture, vec2(clamp(pos.x, 0., 1.), fract(pos.y)));
		
        return vec4(0.);
    }
    vec4 sampleTexture( sampler2D texture, vec2 pos) { return sampleTexture(texture, pos, 0.); }
#endregion -- sampler_simple --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec2  position;
uniform float seed;
uniform int   mode;
uniform int   aa;

uniform vec2      scale;
uniform int       scaleUseSurf;
uniform sampler2D scaleSurf;

uniform vec2      angle;
uniform int       angleUseSurf;
uniform sampler2D angleSurf;

uniform vec2      thick;
uniform int       thickUseSurf;
uniform sampler2D thickSurf;

uniform vec2  level;

uniform int   textureTransform;
uniform float textureSeed;
uniform vec4  texturePosition;
uniform vec2  textureAngle;
uniform vec4  textureScale;
uniform float textureFlip;

uniform float phase;

uniform vec4  gapCol;
uniform int   gradient_use;

#define PI  3.14159265359
#define TAU 6.28318530718

float random (in vec2 st) {	return fract(sin(dot(st.xy + vec2(85.456034, 64.54065), vec2(12.9898, 78.233))) * (43758.5453123 + seed) ); }
float random (in float sd) { return random(vec2(sd)); }

float HexDist(vec2 p) {
	p = abs(p);
    
    float c = dot(p, normalize(vec2(1, 1.73)));
    c = max(c, p.x);
    
    return c;
}

mat2 rot2D(float a) { return mat2(cos(a), -sin(a), sin(a), cos(a)); }

vec3 sdBox( in vec2 p, in float b ) {
    vec2 d = abs(p) - b;
    return vec3( max(d.x, d.y), step(vec2(0), d) );
}

float round(float val) { return fract(val) >= 0.5? ceil(val) : floor(val); }

vec4 PytagoreanCoords(vec2 uv) {
	float a = radians(phase) / 4.;
    float q = mod(round(a / (TAU / 4.)), 2.);
    
    vec2 p = uv * 2.;
    
    p *= rot2D(a);
    
    vec2 p1 = fract(p) - 0.5;
    vec2 sp = sign(p1);
    vec2 p2 = (abs(p1) - 0.5) * sp;
    
    vec2 id = (p - p1) * 2.;
    
    p1 *= rot2D(-a);
    p2 *= rot2D(-a);
    
    vec2 sp2 = sign(p1);
    vec2 s   = abs(vec2(cos(a), sin(a))) * 0.5;
    
    vec3 d1 = sdBox(p1, s.x);
    vec3 d2 = sdBox(p2, s.y);
    
    float m  = q > 0.5 ? step(0., d1.x) : step(d2.x, 0.);
    float s1 = mod(ceil(abs((a - PI) / (PI / 4.))), 2.) * 2. - 1.;
    float s2 = q * 2. - 1.;
    float ss = s1 * s2 * 2.;
    
    id += sp * m;
    
    float m2 = clamp(sign(d1.x) + sign(d2.x), 0., 1.);
    
    id += d1.yz * sp2 * ss * m2;
    
    float size = m < 0.5 ? s.x : s.y;
    vec2  puv  = (p - id * 0.5) / size * rot2D(-a) * 0.5;
    
    vec2 dp = (0.5 - abs(puv)) * size;
    float d = min(dp.x, dp.y);
	
	return vec4(random(id), d, puv);
}

void main() {
	#region params
		vec2 sca = scale;
		if(scaleUseSurf == 1) {
			vec4 _vMap = texture2D( scaleSurf, v_vTexcoord );
			sca = vec2(mix(scale.x, scale.y, (_vMap.r + _vMap.g + _vMap.b) / 3.));
		}
		sca = dimension / sca / 4.;
		
		float ang = angle.x;
		if(angleUseSurf == 1) {
			vec4 _vMap = texture2D( angleSurf, v_vTexcoord );
			ang = mix(angle.x, angle.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		ang = radians(ang);
		
		float thk = thick.x;
		if(thickUseSurf == 1) {
			vec4 _vMap = texture2D( thickSurf, v_vTexcoord );
			thk = mix(thick.x, thick.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
	#endregion
	
	thk = clamp(thk, 0., 1.);
	thk = pow(thk, 3.);
	
	vec2 vtx = getUV(v_vTexcoord);
	mat2 rot = mat2(cos(ang), - sin(ang), sin(ang), cos(ang));
	vec2 asp = vec2(dimension.x / dimension.y, 1.);
	vec2 pos = (vtx - position) * asp;
	vec2 _pos = pos * rot * sca;
	
    vec4 hc = PytagoreanCoords(_pos);
	vec4 colr;
	
	if(mode == 1) {
		float dist = (hc.y * 2. - level.x) / (level.y - level.x);
		gl_FragColor = vec4(vec3(dist), 1.0);
		return;
	}
	
	if(mode == 0) {
		colr = gradientEval(abs(hc.x));
	} else if(mode == 2) {
		vec2 uv = hc.zw + vec2(0.5, 0.5);
		vec2 dx = hc.xx;
		
		if(textureTransform == 1) { 
			float rx = random(hc.xx + textureSeed / 100.);
			float ry = random(hc.xx + textureSeed / 100. + vec2(0.4864, 0.6879));
			
			if(rx > textureFlip) uv.x = 1. - uv.x;
			if(ry > textureFlip) uv.y = 1. - uv.y;
			
			float tseed = random(dx + textureSeed / 100. + vec2(0.9843, 0.1636));
			float ang   = textureAngle.x + (textureAngle.y - textureAngle.x) * random(tseed + 0.);
			      ang   = radians(ang);
			
			vec2  tpos  = vec2( mix(texturePosition[0], texturePosition[2], random(tseed + 1.)),
				                mix(texturePosition[1], texturePosition[3], random(tseed + 2.)));
				                
			vec2  tsca  = vec2( mix(textureScale[0], textureScale[1], random(tseed + 3.)),
				                mix(textureScale[2], textureScale[3], random(tseed + 4.)));
			
			uv -= .5;
			uv *= mat2(cos(ang), -sin(ang), sin(ang), cos(ang));
			uv /= tsca;
			uv += .5;
			uv -= tpos;
		}
		
		colr = sampleTexture( gm_BaseTexture, uv );
	}
	
	float _aa = 3. / max(dimension.x, dimension.y);
	gl_FragColor = mix(gapCol, colr, aa == 1? smoothstep(thk - _aa, thk, hc.y) : step(thk, hc.y));
}