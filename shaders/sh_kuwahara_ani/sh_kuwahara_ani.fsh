varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define MAX_RAD 64

uniform vec2 dimension;
uniform int  radius;

void main () {
	gl_FragColor = texture2D(gm_BaseTexture, v_vTexcoord);
	
	vec2  tx = 1. / dimension;
    float n  = float((radius + 1) * (radius + 1));
	
    vec3 m[4];
    vec3 s[4];
	vec3 c;
	
    for (int k = 0; k < 4; ++k) {
        m[k] = vec3(0.0);
        s[k] = vec3(0.0);
    }

    for (int j = 0; j <= MAX_RAD; j++) 
    for (int i = 0; i <= MAX_RAD; i++) {
		if(i > radius) continue;
		if(j > radius) break;
		
        c = texture2D(gm_BaseTexture, v_vTexcoord + vec2(-i,  -j) * tx).rgb;
        m[0] += c;
        s[0] += c * c;
		
        c = texture2D(gm_BaseTexture, v_vTexcoord + vec2( i,  -j) * tx).rgb;
        m[1] += c;
        s[1] += c * c;
		
        c = texture2D(gm_BaseTexture, v_vTexcoord + vec2( i,   j) * tx).rgb;
        m[2] += c;
        s[2] += c * c;
		
        c = texture2D(gm_BaseTexture, v_vTexcoord + vec2(-i,   j) * tx).rgb;
        m[3] += c;
        s[3] += c * c;
    }
	
    float min_sigma2 = 100.;
    for (int k = 0; k < 4; k++) {
        m[k] /= n;
        s[k] = abs(s[k] / n - m[k] * m[k]);
		
        float sigma2 = s[k].r + s[k].g + s[k].b;
        if (sigma2 < min_sigma2) {
            min_sigma2 = sigma2;
            gl_FragColor = vec4(m[k], 1.0);
        }
    }
}