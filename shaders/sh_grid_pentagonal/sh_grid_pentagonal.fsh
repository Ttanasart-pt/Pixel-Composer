#pragma use(uv)

#region -- uv -- [1770002023.9166503]
    uniform sampler2D uvMap;
    uniform int   useUvMap;
    uniform float uvMapMix;

    vec2 getUV(in vec2 uv) {
        if(useUvMap == 0) return uv;

        vec2 vuv   = texture2D( uvMap, uv ).xy;
             vuv.y = 1.0 - vuv.y;

        vec2 vtx = mix(uv, vuv, uvMapMix);
        return vtx;
    }
#endregion -- uv --
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
//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

//sqrt of 3
#define r3 1.73205080757

uniform vec2  position;
uniform vec2  dimension;
uniform float seed;
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

uniform vec4  gapCol;
uniform int   gradient_use;
uniform vec2  level;

float random (in vec2 st) { return fract(sin(dot(st.xy + vec2(85.456034, 64.54065), vec2(12.9898, 78.233))) * (43758.5453123 + seed) ); }

float sdLine(vec2 a, vec2 b, float r, vec2 p){
    vec2 ab = b - a;
    float t = dot(p - a, ab) / dot(ab, ab);
    vec2 p2 = a + clamp(t, 0.0, 1.0) * ab;
    return length(p - p2) - r;
}

//draws the lines between the pentagons
float pentagrid(vec2 uv) {
    vec2 cuv = floor(uv / r3);
    uv = fract(uv / r3) * r3;
    float d = 9999999.;
	
    //checkerboard pattern where alternate cells are transposed
    if (mod(cuv.x, 2.0) == mod(cuv.y, 2.0)){
		
        d = min(d, sdLine(vec2(r3 / 2.0 - 0.5, 0.), vec2(r3 / 2.0 + 0.5, r3), 0.01, uv));
        d = min(d, sdLine(vec2(0., r3 / 2.0 + 0.5), vec2(r3, r3 / 2.0 - 0.5), 0.01, uv));
        d = min(d, sdLine(vec2(0., 0.), vec2(r3 / 2.0 - 0.5, 0.), 0.01, uv));
        d = min(d, sdLine(vec2(r3, r3), vec2(r3 / 2.0 + 0.5, r3), 0.01, uv));
        d = min(d, sdLine(vec2(0., r3), vec2(0., r3 / 2.0 + 0.5), 0.01, uv));
        d = min(d, sdLine(vec2(r3, 0.), vec2(r3, r3 / 2.0 - 0.5), 0.01, uv));
		
    } else {
		
        d = min(d, sdLine(vec2(0., r3 / 2.0 - 0.5),vec2(r3, r3 / 2.0 + 0.5), 0.01, uv));
        d = min(d, sdLine(vec2(r3 / 2.0 + 0.5, 0.),vec2(r3 / 2.0 - 0.5, r3), 0.01, uv));
        d = min(d, sdLine(vec2(0., 0.),vec2(0., r3 / 2.0 - 0.5), 0.01, uv));
        d = min(d, sdLine(vec2(r3, r3),vec2(r3, r3 / 2.0 + 0.5), 0.01, uv));
        d = min(d, sdLine(vec2(r3, 0.),vec2(r3 / 2.0 + 0.5, 0.), 0.01, uv));
        d = min(d, sdLine(vec2(0., r3),vec2(r3 / 2.0 - 0.5, r3), 0.01, uv));
    }
    return d;
}

//returns the incenter of the pentagon a point is in
vec2 pentacoords(vec2 uv){
    vec2 cuv = floor(uv / r3);
    uv = fract(uv / r3) * r3;
    //checkerboard pattern where alternate cells are transposed
    if (mod(cuv.x, 2.0) == mod(cuv.y, 2.0)){
		
        vec2 ruv = mat2(-r3, -1., 1., -r3) * (uv - r3 / 2.0) * 0.25; //change of basis to "windmill" basis
        cuv *= r3;
		
        if (ruv.x < 0.0 && ruv.y < 0.0)
            return cuv + vec2(r3, (3.0 * r3 - 3.0) / 2.0); //right
			
        else if (ruv.x > 0.0 && ruv.y < 0.0)
            return cuv + vec2((3.0 - r3) / 2.0, r3); //up
			
        else if (ruv.x < 0.0 && ruv.y > 0.0)
            return cuv + vec2((3.0 * r3 - 3.0) / 2.0, 0.); //down
			
        else
            return cuv + vec2(0., (3.0 - r3) / 2.0); //left
        
    } else {
        cuv *= r3;
        vec2 ruv = mat2(r3, 1., 1., -r3) * (uv - r3 / 2.0) * 0.25; //change of basis to "anti-windmill" basis
		
        if (ruv.x < 0.0 && ruv.y < 0.0)
            return cuv + vec2(r3, (3.0 * r3 - 3.0) / 2.0) - vec2(r3, 0.); //up
			
        else if (ruv.x > 0.0 && ruv.y < 0.0)
            return cuv + vec2((3.0 * r3 - 3.0) / 2.0, 0.) + vec2(0., r3); //left
			
        else if (ruv.x < 0.0 && ruv.y > 0.0)
            return cuv + vec2((3.0 - r3) / 2.0, r3) - vec2(0., r3); //right
			
        else
            return cuv + vec2(0., (3.0 - r3) / 2.0) + vec2(r3, 0); //down
        
    }
}

void main() {
	#region params
		vec2 sca = scale;
		if(scaleUseSurf == 1) {
			vec4 _vMap = texture2D( scaleSurf, v_vTexcoord );
			sca = vec2(mix(scale.x, scale.y, (_vMap.r + _vMap.g + _vMap.b) / 3.));
		}
		sca = dimension / sca;
		
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
		
		wid -= 0.05;
	#endregion
	
	vec2 vtx = getUV(v_vTexcoord);
	mat2 rot = mat2(cos(ang), - sin(ang), sin(ang), cos(ang));
	vec2 asp = vec2(dimension.x / dimension.y, 1.);
	vec2 pos = (vtx - position) * asp;
	vec2 _pos = pos * rot * sca;
	
	vec2  coord = pentacoords(_pos);
	float dist  = pentagrid(_pos);
	vec4 colr;
	
	if(mode == 0) {
		vec2 coordw = fract(fract(coord / sca) + 1.);
		colr = gradientEval(random(coordw));
		
	} else if(mode == 1) {
		dist = (dist - level.x) / (level.y - level.x);
		colr = vec4(vec3(dist), 1.);
		
	} else if(mode == 2) {
		vec2 uv = fract(fract(coord / sca) + 1.);
		colr = texture2D( gm_BaseTexture, uv );
		
	}
	
	float _aa = 4. / max(dimension.x, dimension.y);
    gl_FragColor = mix(gapCol, colr, aa == 1? smoothstep(wid - _aa, wid, dist) : step(wid, dist));
}