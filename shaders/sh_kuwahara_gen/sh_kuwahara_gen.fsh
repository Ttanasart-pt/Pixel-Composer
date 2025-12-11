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

#define PI 3.14159265358979323846
#define N 8

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform float hardness, sharpness, zeroCrossing;

uniform vec2      radius;
uniform int       radiusUseSurf;
uniform sampler2D radiusSurf;

void main() {
	float rad    = radius.x;
	float radMax = max(radius.x, radius.y);
	if(radiusUseSurf == 1) {
		vec4 _vMap = texture2D( radiusSurf, v_vTexcoord );
		rad = mix(radius.x, radius.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec2 tx = 1. / dimension;
    vec4 m[8];
    vec3 s[8];

    float kernelRadius = rad / 2.;
	float zeta = 2.0 / kernelRadius;
    //float zeta = _Zeta;

    float sinZeroCross = sin(zeroCrossing);
    float eta = (zeta + cos(zeroCrossing)) / (sinZeroCross * zeroCrossing);

    for (int k = 0; k < N; ++k) {
        m[k] = vec4(0.0);
        s[k] = vec3(0.0);
    }

    for (float y = -radMax; y <= radMax; ++y) {
    	if(y < -rad) continue;
    	if(y >  rad) break;
    	
	    for (float x = -radMax; x <= radMax; ++x) {
	    	if(x < -rad) continue;
    		if(x >  rad) break;
    		
	        vec2 v = vec2(x, y) / kernelRadius;
	        vec3 c = sampleTexture(gm_BaseTexture, v_vTexcoord + vec2(x, y) * tx, length(v)).rgb;
	        c = clamp(c, 0., 1.);
	        
	        float sum = 0.;
	        float w[8];
	        float z, vxx, vyy;
	        
	        /* Calculate Polynomial Weights */
	        vxx = zeta - eta * v.x * v.x;
	        vyy = zeta - eta * v.y * v.y;
	        z = max(0., v.y + vxx); 
	        w[0] = z * z;
	        sum += w[0];
	        
	        z = max(0., -v.x + vyy); 
	        w[2] = z * z;
	        sum += w[2];
	        
	        z = max(0., -v.y + vxx); 
	        w[4] = z * z;
	        sum += w[4];
	        
	        z = max(0., v.x + vyy); 
	        w[6] = z * z;
	        sum += w[6];
	        
	        v = sqrt(2.0) / 2.0 * vec2(v.x - v.y, v.x + v.y);
	        vxx = zeta - eta * v.x * v.x;
	        vyy = zeta - eta * v.y * v.y;
	        z = max(0., v.y + vxx); 
	        w[1] = z * z;
	        sum += w[1];
	        
	        z = max(0., -v.x + vyy); 
	        w[3] = z * z;
	        sum += w[3];
	        
	        z = max(0., -v.y + vxx); 
	        w[5] = z * z;
	        sum += w[5];
	        
	        z = max(0., v.x + vyy); 
	        w[7] = z * z;
	        sum += w[7];
	        
	        float g = exp(-3.125 * dot(v,v)) / sum;
	        
	        for (int k = 0; k < 8; ++k) {
	            float wk = w[k] * g;
	            m[k] += vec4(c * wk, wk);
	            s[k] += c * c * wk;
	        }
	    }
    }

    vec4 outp = vec4(0.);
    for (int k = 0; k < N; ++k) {
        m[k].rgb /= m[k].w;
        s[k] = abs(s[k] / m[k].w - m[k].rgb * m[k].rgb);
		
        float sigma2 = s[k].r + s[k].g + s[k].b;
        float w = 1.0 / (1.0 + pow(hardness * 1000.0 * sigma2, 0.5 * sharpness));

        outp += vec4(m[k].rgb * w, w);
    }

    gl_FragColor = clamp(outp / outp.w, 0., 1.);
}