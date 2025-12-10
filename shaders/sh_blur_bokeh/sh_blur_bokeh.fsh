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

uniform vec2 dimension;

uniform vec2      strength;
uniform int       strengthUseSurf;
uniform sampler2D strengthSurf;

uniform float iteration;

uniform float contrast;
uniform float contrastFactor;
uniform float smooth;
uniform float rotation;

uniform int   spectralUse;
uniform float spectralIntensity;
uniform float spectralShift;
uniform float spectralScale;

const float phi = 2.39996323;

vec3 bump3y(vec3 x, vec3 yoffset) {
	vec3 y = vec3(1.) - x * x;
	     y = clamp(y - yoffset, 0., 1.);
	return y;
}

vec3 spectral_zucconi6(float x) {
	const vec3 c1 = vec3(3.54585104, 2.93225262, 2.41593945);
	const vec3 x1 = vec3(0.69549072, 0.49228336, 0.27699880);
	const vec3 y1 = vec3(0.02312639, 0.15225084, 0.52607955);

	const vec3 c2 = vec3(3.90307140, 3.21182957, 3.96587128);
	const vec3 x2 = vec3(0.11748627, 0.86755042, 0.66077860);
	const vec3 y2 = vec3(0.84897130, 0.88445281, 0.73949448);

	return bump3y(c1 * (x - x1), y1) +
		   bump3y(c2 * (x - x2), y2) ;
}

void main() {
	float str = strength.x;
	if(strengthUseSurf == 1) {
		vec4 _vMap = texture2D( strengthSurf, v_vTexcoord );
		str = mix(strength.x, strength.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec3  confactor = vec3(contrastFactor);
	
	vec3  res    = vec3(0.);
	vec3  weight = vec3(0.);
	vec3  spec   = vec3(0.);
	
	float alpha  = 0.;
    float rec    = 1.0; // reciprocal 
    vec2  hang   = vec2(0.0, str * 0.01 / sqrt(iteration));
    vec2  asp    = vec2(dimension.y / dimension.x, 1.0);
    
    float ang    = phi * (1. + radians(rotation - 1.) / 100.);
	mat2  rot    = mat2( cos(ang), sin(ang), -sin(ang), cos(ang) );
	
	for (float i = 0.; i < iteration; i++) {
        rec += 1. / rec;
	    hang = hang * rot;
        
        float rat = 1. / iteration;
        vec2  off = (rec - 1.0) * hang;
        vec2  suv = v_vTexcoord + asp * off;
		vec4  sam = sampleTexture(gm_BaseTexture, suv, rat);
        vec3  col = sam.rgb * sam.a;
		vec3  bok = smooth + pow(col, confactor) * contrast;
		
		res		+= col * bok;
		alpha	+= sam.a * (bok.r + bok.g + bok.b) / 3.;
		weight	+= bok;
	}
	
	res   += spec;
	res   /= weight;
	alpha /= (weight[0] + weight[1] + weight[2]) / 3.;
	
	gl_FragColor = vec4(res, alpha);
}
