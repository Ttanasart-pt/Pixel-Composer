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

uniform sampler2D extrudeMap;
uniform vec2  dimension;
uniform vec2  depth;

uniform float angle;
uniform float extDistance;
uniform float shift;

uniform int   cloneColor;
uniform int   wrap;

uniform int   highlight;
uniform vec4  highlightColor;

uniform sampler2D mask;
uniform int    useMask;

void main() {
	vec2 tx  = 1. / dimension;
	vec2 shf = vec2(cos(angle), -sin(angle)) * tx;
	
	float dist = extDistance;
	if(useMask == 1) {
		vec4  mm = texture2D(mask, v_vTexcoord);	
		float ms = (mm.x + mm.y + mm.z) / 3. * mm.a;
		dist = floor(dist * ms + .5);
	}
	
	vec2 vt  = v_vTexcoord - shift * shf * dist;
	
	vec4  baseColor = texture2D(gm_BaseTexture, vt);
	vec4  extData   = texture2D(extrudeMap, v_vTexcoord);
	float extrude   = extData.r;
	
	gl_FragData[0]  = baseColor;
	gl_FragData[1]  = vec4(vec3(extrude == -1.? 0. : 1.), 1.);
	
	if(extrude == -1. && highlight == 1) {
	    vec2 hgc = vec2(shf.x > 0.? 1. : -1., shf.y > 0.? 1. : -1.) * tx;
	    
	    float e1 = texture2D(extrudeMap, v_vTexcoord + vec2(hgc.x, 0.)).r;
	    float e2 = texture2D(extrudeMap, v_vTexcoord + vec2(0., hgc.y)).r;
	    
	    if(e1 > 0. || e2 > 0.) {
	        gl_FragData[0] = mix(gl_FragData[0], vec4(highlightColor.rgb, gl_FragData[0].a), highlightColor.a);
	        gl_FragData[1] = vec4(vec3(mix(depth.x, depth.y, 0.)), 1.);
	    }
	    return;
	}
	
	if(extrude <= 0.) return;
	
	float prog = extrude / dist;
	gl_FragData[0] = gradientEval(prog);
	gl_FragData[1] = vec4(vec3(mix(depth.x, depth.y, prog)), 1.);
	
	if(cloneColor == 0) return;
	
	vec2 pos = vt - shf * extrude;
	if(wrap == 1) pos = fract(fract(pos) + 1.);
	
	vec4 cColor = texture2D(gm_BaseTexture, pos);
	if(cloneColor == 1) gl_FragData[0] *= cColor;
	if(cloneColor == 2) gl_FragData[0] += cColor;
}