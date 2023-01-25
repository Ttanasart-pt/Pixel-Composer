//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float strength;
uniform vec2 center;
uniform int sampleMode;
uniform int blurMode;

uniform int useMask;
uniform sampler2D mask;

float sampleMask() {
	if(useMask == 0) return 1.;
	vec4 m = texture2D( mask, v_vTexcoord );
	return (m.r + m.g + m.b) / 3. * m.a;
}

vec4 sampleTexture(vec2 pos) {
	if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
		return texture2D(gm_BaseTexture, pos);
	
	if(sampleMode == 0) 
		return vec4(0.);
	if(sampleMode == 1) 
		return texture2D(gm_BaseTexture, clamp(pos, 0., 1.));
	if(sampleMode == 2) 
		return texture2D(gm_BaseTexture, fract(pos));
	
	return vec4(0.);
}

void main() {
    vec2 uv = v_vTexcoord - center;
	
	float str = strength * sampleMask();
	float nsamples = 64.;
	float scale_factor = str * (1. / (nsamples * 2. - 1.));
	vec4 color = vec4(0.0);
    float blrStart = 0.;
	
	if(blurMode == 0)
		blrStart = 0.;
	else if(blurMode == 1)
		blrStart = -nsamples;
	else if(blurMode == 2)
		blrStart = -nsamples * 2. - 1.;
	
    for(float i = 0.; i < nsamples * 2. + 1.; i++) {
        float scale = 1.0 + ((blrStart + i) * scale_factor);
		vec2 pos = uv * scale + center;
		color += sampleTexture(pos);
    }
    
    color /= nsamples * 2. + 1.;
    
	gl_FragColor = color;
}

