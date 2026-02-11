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

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

uniform vec2  position;
uniform float rotation;
uniform vec2  scale;
uniform float seed;

uniform int  group;
uniform int  type;
uniform vec4 color1;
uniform vec4 color2;

#define s3 1.73205080757

float random (in vec2 st, float seed) { return fract(sin(dot(st.xy + seed / 1000., vec2(1892.9898, 78.23453))) * 437.54123); }

float frandom (in vec2 st) {
    float n0 = random(st, floor(seed) / 5000.);
	float n1 = random(st, (floor(seed) + 1.) / 5000.);
	return mix(n0, n1, fract(seed));
}

void main() {
	float ang = radians(rotation);
	
	vec2 tx  = getUV(v_vTexcoord);
	     tx -= position / dimension;
	     tx *= mat2(cos(ang), -sin(ang), sin(ang), cos(ang));
	     tx /= scale / dimension;
    
    vec2 cellSize = vec2(s3 + 1., s3);
    vec2 cellIndx = floor(tx / cellSize);
    vec2 cellUV   = (tx - cellIndx * cellSize) / cellSize;
    
    bool flipX = mod(cellIndx.x + cellIndx.y, 2.) == 1.;
    if(flipX) cellUV.x = 1. - cellUV.x;
    
    bool diag = cellUV.x > cellUV.y; 
    if(diag) {
    	cellUV.x = 1. - cellUV.x;
    	cellUV.y = 1. - cellUV.y;
    }
    
    cellUV *= cellSize;
    
    int index = 2;
         if(cellUV.x <      cellUV.y / s3)             index = 0;
    else if(cellUV.x < s3 - cellUV.y / s3 * (s3 - 1.)) index = 1;
    
    vec4 res;
    float gIndex = float(index);
    
    if(group == 0) {
    	if(type == 0) {
    		if(index == 2) index = 0;
    		if(flipX) index = 1 - index;
    		gIndex = float(index);
    		
    	} else {
    		gIndex = float(index) * (flipX? 3.123 : 1.545);
    	}
    	
    } else if(group == 1) { // 3-6 Deltoidal
    	if(type == 0) {
    		gIndex = index == 2? 1. : 0.;
    		
    	} else {
    		gIndex = index == 2? 1. : 0.;
			if(diag && index == 2) cellIndx.y--;
    		
    	}
    	
    } else if(group == 2) { // Rhombile
    	if(type == 0) {
    		gIndex = index == 0? 1. : 0.;
    		
    	} else {
    		gIndex = index == 0? 1. : 0.;
    		
    		if(index == 0) {
	    		if(flipX) {
	    			if(diag) cellIndx.y--;
	    			else     cellIndx.x++;
	    			
	    		} else if(diag) { 
	    			cellIndx.x++; 
	    			cellIndx.y--; 
	    		}
    		}
    	}
    	
    	
    } else if(group == 3) { // Triakis Triangular
    	if(type == 0) {
    		gIndex = index == 0? 1. : 0.;
    		
    	} else {
    		gIndex = index == 0? 1. : 0.;
    		
    		if(index == 0) {
	    		if(flipX) {
	    			if(diag) cellIndx.y--;
	    			
	    		} else if(diag) { 
	    			cellIndx.y--; 
	    		}
    		} else {
    			if(diag) gIndex += 5.486;
    		}
    	}
    	
    } 
    
	if(type == 0) {
		res = gIndex == 0.? color1 : color2;
		
	} else {
		float p = random(cellIndx, seed + gIndex);
		res = gradientEval(p);
		
	}
    	
    gl_FragColor = res;
}