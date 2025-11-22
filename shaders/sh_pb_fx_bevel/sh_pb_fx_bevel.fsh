varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define TAU 6.283185307179586

uniform vec2  dimension;
uniform float height;
uniform float shiftAngle;

uniform sampler2D edgeSurf;

#region //////////////////////////////////// GRADIENT ////////////////////////////////////
	#define GRADIENT_LIMIT 128
	
	uniform int		  height_blend;
	uniform vec4	  height_color[GRADIENT_LIMIT];
	uniform float	  height_time[GRADIENT_LIMIT];
	uniform int		  height_keys;

	uniform int		  radius_blend;
	uniform vec4	  radius_color[GRADIENT_LIMIT];
	uniform float	  radius_time[GRADIENT_LIMIT];
	uniform int		  radius_keys;

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
    
	vec4 gradientEval(in float prog, int gradient_blend, vec4 gradient_color[GRADIENT_LIMIT], float gradient_time[GRADIENT_LIMIT], int gradient_keys) {
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
	}
	
	vec4 gradientHeightEval(in float prog) { return gradientEval(prog, height_blend, height_color, height_time, height_keys); }
	vec4 gradientRadiusEval(in float prog) { return gradientEval(prog, radius_blend, radius_color, radius_time, radius_keys); }
	
#endregion //////////////////////////////////// GRADIENT ////////////////////////////////////

float val(vec4 v) { return (v.r + v.g + v.b) / 3. * v.a; }

void main() {
    vec2 tx = 1. / dimension;
    vec4 cc = texture2D( gm_BaseTexture, v_vTexcoord );
    gl_FragData[0] = cc;
    gl_FragData[1] = vec4(0.);
    if(val(cc) == 0.) return;
    
    vec4 s;
    vec2 p, op;
    vec2  edgPos   = vec2(0.);
    float edgeDist = 0.;
    bool  edgeInv  = false;
    bool  inside   = true;
    float a = 0.;
    float ai = .25;
    
    for(float i = 1.; i <= height; i++) {
        for(float j = 0.; j < 1.; j += ai) {
            a = j * TAU;
            p = v_vTexcoord + vec2( cos(a), sin(a)) * i * tx;
            s = texture2D( gm_BaseTexture, p );
            
            if(val(s) == 0.) { 
            	inside   = false; 
            	edgPos   = p; 
            	edgeDist = i; 
            	edgeInv  = j >= .5; 
            	break; 
            }
        }
        
        if(!inside) break;
    }
    
    if(inside) {
		gl_FragData[1] = vec4(1.);
        return;
    }
    
    float edgeAng = texture2D( edgeSurf, edgPos ).x / 2.;
    if(edgeInv) edgeAng = .5 + edgeAng;
    edgeAng = fract(edgeAng - shiftAngle);
    
    float slope   = edgeDist / (height + 1.);
    
    vec4 height_color = gradientHeightEval(slope);
    vec4 radius_color = gradientRadiusEval(edgeAng);
    gl_FragData[0] = height_color * radius_color;
    
}
