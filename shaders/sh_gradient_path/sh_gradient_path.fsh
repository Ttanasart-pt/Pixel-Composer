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

uniform vec2      dimension;
uniform sampler2D mask;
uniform int       useMask;

uniform vec2      shift;
uniform int       shiftUseSurf;
uniform sampler2D shiftSurf;

uniform vec2      scale;
uniform int       scaleUseSurf;
uniform sampler2D scaleSurf;

uniform int type;
uniform int gradient_loop;

uniform float pathPoints[1024];
uniform int   pathRes;

void main() {
	#region params
		float shf = shift.x;
		if(shiftUseSurf == 1) {
			vec4 _vMap = texture2D( shiftSurf, v_vTexcoord );
			shf = mix(shift.x, shift.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float sca = scale.x;
		if(scaleUseSurf == 1) {
			vec4 _vMap = texture2D( scaleSurf, v_vTexcoord );
			sca = mix(scale.x, scale.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
	#endregion
	
	float maskA = useMask == 1? texture2D( mask, v_vTexcoord ).a : 1.;
	float prog  = 0.;
	vec2  pp    = v_vTexcoord;
	
	float minDist = 99999.;
	for(int i = 0; i < pathRes; i++) {
		vec2 p0 = vec2(pathPoints[i*2+0], pathPoints[i*2+1]);
		vec2 p1 = vec2(pathPoints[i*2+2], pathPoints[i*2+3]);
		
		vec2 pa = pp - p0;
		vec2 ba = p1 - p0;
		float h = clamp(dot(pa, ba) / dot(ba, ba), 0., 1.);
		
		vec2  pntS = p0 + ba * h;
		float dis  = distance(pp, pntS);
		
		if(dis < minDist) {
			minDist = dis;
			prog = (float(i) + h) / float(pathRes);
			// prog = h;
		}
	}
	
	float p;
	     if(type == 0) p = (prog + shf - .5) / sca + .5;
	else if(type == 1) p = (minDist + shf) / sca;
	
	     if(gradient_loop == 1) p = fract(fract(p) + 1.);
	else if(gradient_loop == 2) p = 1. - abs(mod(p, 2.) - 1.);
	
	vec4 col = gradientEval(p);
	gl_FragColor = vec4(col.rgb, col.a * maskA);
}