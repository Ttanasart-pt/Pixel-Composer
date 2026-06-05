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

uniform vec2 dimension;

uniform sampler2D heightmap;
uniform sampler2D texture;

uniform sampler2D textureSide;
uniform sampler2D textureFront;

uniform int textureSide_use;
uniform int textureFront_use;

uniform vec3  angle;
uniform vec3  position;

uniform int   projection;
uniform float fov;
uniform float distant;
uniform float scale;

#region ////========== Transform ============
    mat3 rotateX(float dg) {
        float c = cos(radians(dg));
        float s = sin(radians(dg));
        return mat3(
            vec3(1, 0,  0),
            vec3(0, c, -s),
            vec3(0, s,  c)
        );
    }
    
    mat3 rotateY(float dg) {
        float c = cos(radians(dg));
        float s = sin(radians(dg));
        return mat3(
            vec3( c, 0, s),
            vec3( 0, 1, 0),
            vec3(-s, 0, c)
        );
    }
    
    mat3 rotateZ(float dg) {
        float c = cos(radians(dg));
        float s = sin(radians(dg));
        return mat3(
            vec3(c, -s, 0),
            vec3(s,  c, 0),
            vec3(0,  0, 1)
        );
    }
    
    mat3 inverse(mat3 m) {
        float a00 = m[0][0], a01 = m[0][1], a02 = m[0][2];
        float a10 = m[1][0], a11 = m[1][1], a12 = m[1][2];
        float a20 = m[2][0], a21 = m[2][1], a22 = m[2][2];
        
        float b01 = a22 * a11 - a12 * a21;
        float b11 = -a22 * a10 + a12 * a20;
        float b21 = a21 * a10 - a11 * a20;
        
        float det = a00 * b01 + a01 * b11 + a02 * b21;
        
        return mat3(b01, (-a22 * a01 + a02 * a21), (a12 * a01 - a02 * a11),
                  b11, (a22 * a00 - a02 * a20), (-a12 * a00 + a02 * a10),
                  b21, (-a21 * a00 + a01 * a20), (a11 * a00 - a01 * a10)) / det;
    }
#endregion

void main() {
	mat3 rx = rotateX(angle.x);
    mat3 ry = rotateY(angle.y);
    mat3 rz = rotateZ(angle.z);
    mat3 rotMatrix  = rx * ry * rz;
    mat3 irotMatrix = inverse(rotMatrix);
	
	vec2 uv = v_vTexcoord - .5;
	vec3 dir, eye;
	
	if(projection == 0) {
		float dz  = 1. / tan(radians(fov) / 2.);
		
		dir = vec3(uv * 2., -dz);
		eye = vec3(0., 0., sqrt(3.) * distant);
			
	} else if(projection == 1) {
		dir = vec3(0., 0., -1.);
    	eye = vec3(uv * scale, sqrt(3.));
	}
	
	eye -= position;
	
	dir = irotMatrix * dir;
	dir = normalize(dir);
	eye = irotMatrix * eye;
	
	float size    = max(dimension.x, dimension.y);
	float voxSize = 2.0 / size;
    
    if(abs(dir.x) < .001) dir.x = .001; // prevent divided by zero. TODO: implement proper code when dealing with 2d projection
    if(abs(dir.y) < .001) dir.y = .001;
    if(abs(dir.z) < .001) dir.z = .001;
	
    vec3 ro  = eye / voxSize;
    vec3 rd  = dir;
    vec3 pos = floor(ro);
    vec3 ri  = 1.0 / rd;
    vec3 rs  = sign(rd);
    vec3 dis = (pos - ro + 0.5 + rs * 0.5) * ri;
    
	vec4 samHei = vec4(0.);
    vec3 mm     = vec3(0.);
	bool hit    = false;

	float maxVoxels = sqrt(3.) * size * 2.;
	if(projection == 0) maxVoxels *= distant;
	
    for (float i = 0.; i < maxVoxels; i++) {
        vec3 wc = (pos + 0.5) * voxSize;
        vec3 sc = wc * .5 + .5;
        
        if (sc.x >= 0. && sc.x < 1. && sc.y >= 0. && sc.y < 1. && sc.z >= 0. && sc.z < 1.) {
            samHei = texture2D(heightmap, vec2(sc.x, sc.z));
            
            if (sc.y > 1. - samHei.r) { hit = true; break; }
        }
        
        mm   = step(dis.xyz, dis.yzx) * step(dis.xyz, dis.zxy);
        dis += mm * rs * ri;
        pos += mm * rs;
    }
	
	if (!hit) { gl_FragColor = vec4(0.); return; }
    
    vec3 fmini  = (pos - ro + 0.5 - 0.5 * vec3(rs)) * ri;
    float ft    = max(fmini.x, max(fmini.y, fmini.z));
    vec3 hitPos = (ro + rd * ft) * voxSize;
    vec3 samPos = hitPos * .5 + .5;
    
    gl_FragColor = texture2D(texture, vec2(samPos.x, samPos.z));
    
    	 if (textureSide_use  == 1 && mm.z > 0.5 && (samPos.z <= 0. || samPos.z >= 1.)) gl_FragColor = texture2D(textureSide,  vec2(   samPos.x, samPos.y));
	else if (textureFront_use == 1 && mm.x > 0.5 && (samPos.x <= 0. || samPos.x >= 1.)) gl_FragColor = texture2D(textureFront, vec2(1.-samPos.z, samPos.y));
    
    vec4 heightColor = gradientEval(1. - samPos.y);
    gl_FragColor *= heightColor;
}