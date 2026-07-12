#pragma use(gradient)
#region -- gradient -- [1777679826.681391]
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

	float hueLerp(float a0, float a1, float t) {
		float da = fract(a1 - a0);
	    float ds = fract(2. * da) - da;
	    return a0 + ds * t;
	}

	float hueLerpInv(float a0, float a1, float t) {
		float da = fract(a1 - a0);
	    float ds = fract(2. * da) - da;
	    ds -= sign(ds);
		return a0 + ds * t;
	}

	vec3 hsvMix(vec3 c1, vec3 c2, float t, bool inv) {
		vec3 h1 = rgb2hsv(c1);
		vec3 h2 = rgb2hsv(c2);
	
		vec3 h = vec3(0.);
		h.x = inv ? hueLerpInv(h1.x, h2.x, t) : hueLerp(h1.x, h2.x, t);
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
						return vec4(hsvMix(c0, c1, t, false), a);
						
					else if(gradient_blend == 5)
						return vec4(hsvMix(c0, c1, t, true), a);
						
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

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float seed;
uniform vec2  dimension;

uniform sampler2D mask;
uniform int       useMask;

uniform int       type;
uniform vec2      origin;

uniform vec2      range;
uniform int       rangeUseSurf;
uniform sampler2D rangeSurf;

uniform int       emptyMode;
uniform vec4      emptyColor;

uniform vec2      airDensity;
uniform int       airDensityUseSurf;
uniform sampler2D airDensitySurf;

uniform vec2      solidDensity;
uniform int       solidDensityUseSurf;
uniform sampler2D solidDensitySurf;

uniform vec2      solidDiffuse;
uniform int       solidDiffuseUseSurf;
uniform sampler2D solidDiffuseSurf;

uniform vec2      intensity;
uniform int       intensityUseSurf;
uniform sampler2D intensitySurf;

uniform int       lightAttn;
uniform float     brightness;
uniform vec2      level;

uniform float     subdiv;

float random(in vec2 st, float seed) { return fract(sin(dot(st.xy, vec2(1892.9898, 78.23453))) * (seed + 437.54123)); }

void main() {
	#region params
		float ran = range.x;
		if(rangeUseSurf == 1) {
			vec4 _vMap = texture2D( rangeSurf, v_vTexcoord );
			ran = mix(range.x, range.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float airDen = airDensity.x;
		if(airDensityUseSurf == 1) {
			vec4 _vMap = texture2D( airDensitySurf, v_vTexcoord );
			airDen = mix(airDensity.x, airDensity.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float solDen = solidDensity.x;
		if(solidDensityUseSurf == 1) {
			vec4 _vMap = texture2D( solidDensitySurf, v_vTexcoord );
			solDen = mix(solidDensity.x, solidDensity.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float solDif = solidDiffuse.x;
		if(solidDiffuseUseSurf == 1) {
			vec4 _vMap = texture2D( solidDiffuseSurf, v_vTexcoord );
			solDif = mix(solidDiffuse.x, solidDiffuse.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float ints = intensity.x;
		if(intensityUseSurf == 1) {
			vec4 _vMap = texture2D( intensitySurf, v_vTexcoord );
			ints = mix(intensity.x, intensity.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
	#endregion
	
	vec2  oriTx    = v_vTexcoord; 
	vec2  tx       = 1. / dimension;
	vec2  originTx = origin * tx;
	float rad      = ran    * tx.x;
	
	float pdist = distance(origin, oriTx * dimension);
	
	vec2  dirr;
	float dist;
	
	if(type == 0) {
		dirr = normalize(originTx - oriTx);
		dist = distance(originTx, oriTx);
		
	} else if(type == 1) {
		dirr = normalize(originTx - .5);
		dist = distance(originTx, oriTx);
		
	} else if(type == 2) {
		dirr  = normalize(originTx - .5);
		dist  = distance(originTx, oriTx);
		pdist = dimension.x + dimension.y;
		
		oriTx = v_vTexcoord - dirr * pdist / 2. * tx;
	}
	
	float lightInt  = max(0., (rad - dist) / rad);
	
	     if(lightAttn == 0) lightInt = lightInt;
	else if(lightAttn == 1) lightInt = lightInt * lightInt;
	else if(lightAttn == 2) lightInt = 1. - (1. - lightInt) * (1. - lightInt);
	else if(lightAttn == 3) lightInt = 1.;
	
	vec4  lightCol = gradientEval(lightInt);
	vec4  sampCol  = vec4(0.);
	
	float subStep = 1. / subdiv;
	
	vec4  emCol = emptyMode == 0? emptyColor : texture2D(gm_BaseTexture, originTx);
	vec3  empCl = emCol.rgb * emCol.a;
	
	for(float i = 0.; i < pdist; i += subStep) {
		vec2 sampTx = oriTx + dirr * tx * i;
		
		if(sampTx.x < 0. || sampTx.y < 0. || sampTx.x >= 1. || sampTx.y >= 1.)
			continue;
			
		vec4  sampC = useMask == 0? texture2D(gm_BaseTexture, sampTx) : texture2D(mask, sampTx);
		float sampL = (sampC.r + sampC.g + sampC.b) / 3. * sampC.a;
		      sampL = (sampL - level.x) / (level.y - level.x);
		
		if(sampC.rgb * sampC.a == empCl) {
			lightInt -= airDen * subStep;
			continue;
		}
		
		if(sampL > 0.) {
			lightInt -= solDen * sampL * subStep;
			sampCol  += solDen * solDif * sampC * subStep * lightInt;
			
		} else 
			lightInt -= airDen * subStep;
		
	}
	
	vec4 lig    = lightCol * brightness;
	     lig.a *= lightInt;
	
	vec4 res  = sampCol * lightCol + lig;
		 res *= ints;
         res  = max(res, 0.);
	
	gl_FragColor = res;
}