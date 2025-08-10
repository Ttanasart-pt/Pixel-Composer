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

#define N 8

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D tfm;
uniform vec2 dimension;

uniform float alpha;
uniform int   kernelSize;
uniform float zeroCrossing;
uniform float hardness;
uniform float sharpness;

void main() {
	vec2  tx = 1. / dimension;
	float al = alpha;
	vec4  t  = texture2D(tfm, v_vTexcoord);
	
	float kernelRadius = float(kernelSize / 2);
	float a = kernelRadius * clamp((al + t.w) / al, 0.1, 2.0);
	float b = kernelRadius * clamp(al / (al + t.w), 0.1, 2.0);
	
	float cos_phi = cos(t.z);
	float sin_phi = sin(t.z);
	
	mat2 R = mat2(cos_phi, -sin_phi, sin_phi, cos_phi);
	mat2 S = mat2(0.5 / a, 0.0, 0.0, 0.5 / b);
	mat2 SR = S * R;
	
	int max_x = int(sqrt(a * a * cos_phi * cos_phi + b * b * sin_phi * sin_phi));
	int max_y = int(sqrt(a * a * sin_phi * sin_phi + b * b * cos_phi * cos_phi));
	
	float zeta = 2.0 / kernelRadius;
	//float zeta = _Zeta;
	
	float zeroCross = zeroCrossing;
	float sinZeroCross = sin(zeroCross);
	float eta = (zeta + cos(zeroCross)) / (sinZeroCross * sinZeroCross);
	vec4 m[8];
	vec3 s[8];
	
	for (int k = 0; k < N; ++k) {
	    m[k] = vec4(0.0);
	    s[k] = vec3(0.0);
	}
	
	for (int y = -max_y; y <= max_y; ++y)
    for (int x = -max_x; x <= max_x; ++x) {
        vec2 v = SR * vec2(x, y);
        if (dot(v, v) > 0.25) continue;
        
        vec3 c = sampleTexture(gm_BaseTexture, v_vTexcoord + vec2(x, y) * tx).rgb;
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