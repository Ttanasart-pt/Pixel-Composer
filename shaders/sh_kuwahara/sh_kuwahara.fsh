#pragma use(sampler_simple)

#region -- sampler_simple -- [1729740692.1417658]
    uniform int  sampleMode;
    
    vec4 sampleTexture( sampler2D texture, vec2 pos) {
        if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
            return texture2D(texture, pos);
        
             if(sampleMode <= 1) return vec4(0.);
        else if(sampleMode == 2) return texture2D(texture, clamp(pos, 0., 1.));
        else if(sampleMode == 3) return texture2D(texture, fract(pos));
        else if(sampleMode == 4) return vec4(vec3(0.), 1.);
        
        return vec4(0.);
    }
#endregion -- sampler_simple --

/*
Generalized Kuwahara filter, based on work of Acerola
Basically Acerola code rewritten to Shadertoy
- https://www.youtube.com/watch?v=LDhN-JK3U9g
- https://github.com/GarrettGunnell/Post-Processing/tree/main/Assets/Kuwahara%20Filter
*/

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define PI 3.14159265358979323846;
#define MAX_RAD 64

const float q = 18.;

uniform vec2 dimension;
uniform int  radius;

void main () {
    vec2  tx        = 1. / dimension;
    float zeta      = 2. / float(radius);
    float zeroCross = 2.;

    float sinZeroCross = sin(zeroCross);
    float eta = 0.;
    vec4  m[8];
    vec3  s[8];
	
    for (int k = 0; k < 8; ++k) {
        m[k] = vec4(0.);
        s[k] = vec3(0.);
    }
	
    for (int y = -MAX_RAD; y <= MAX_RAD; y++)
    for (int x = -MAX_RAD; x <= MAX_RAD; x++) {
		if(y < -radius) continue;
		if(x < -radius) continue;
		if(x >  radius) continue;
		if(y >  radius) break;
		
        vec2  v   = vec2(x, y) / float(radius);
        vec3  c   = sampleTexture( gm_BaseTexture, v_vTexcoord + vec2(x, y) * tx).xyz;
		      c   = clamp(c, 0., 1.);
        float sum = 0.;
		
		float w[8];
        float z, vxx, vyy;
		
        /* Calculate Polynomial Weights */
        vxx  = zeta - eta * v.x * v.x;
        vyy  = zeta - eta * v.y * v.y;
        z    = max(0., v.y + vxx); 
        w[0] = z * z;
        sum += w[0];
        z    = max(0., -v.x + vyy); 

        w[2] = z * z;
        sum += w[2];
        z    = max(0., -v.y + vxx); 
		
        w[4] = z * z;
        sum += w[4];
        z    = max(0., v.x + vyy); 
		
        w[6] = z * z;
        sum += w[6];
        v    = sqrt(2.0) / 2.0 * vec2(v.x - v.y, v.x + v.y);
        vxx  = zeta - eta * v.x * v.x;
        vyy  = zeta - eta * v.y * v.y;
		
        z    = max(0., v.y + vxx); 
        w[1] = z * z;
        sum += w[1];
		
        z    = max(0., -v.x + vyy); 
        w[3] = z * z;
        sum += w[3];
		
        z    = max(0., -v.y + vxx); 
        w[5] = z * z;
        sum += w[5];
		
        z    = max(0., v.x + vyy); 
        w[7] = z * z;
        sum += w[7];
		
        float g = exp(-3.125 * dot(v, v)) / (sum + 0.0001);

        for (int k = 0; k < 8; k++) {
            float wk = w[k] * g;
            m[k]    += vec4(c * wk, wk);
            s[k]    += c * c * wk;
        }
    }
	
    vec4 ou = vec4(0.);
	
    for (int k = 0; k < 8; k++) {
        m[k].rgb /= m[k].w;
        s[k]      = abs(s[k] / m[k].w - m[k].rgb * m[k].rgb);

        float sigma2 = s[k].r + s[k].g + s[k].b;
        float w      = 1.0 / (1.0 + pow(1000.0 * sigma2, 0.5 * q));

        ou += vec4(m[k].rgb * w, w);
    }

    gl_FragColor = clamp((ou / ou.w), 0.0, 1.0);
}