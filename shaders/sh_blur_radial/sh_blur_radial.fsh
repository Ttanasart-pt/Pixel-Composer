//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float strength;
uniform vec2  center;

const float nsamples = 32.;

void main() {
    vec2 uv = v_vTexcoord - center;
	float precompute = strength * (1. / (nsamples - 1.));
	vec4 color = vec4(0.0);
	float blurStart = 1.0;
    
    for(float i = 0.; i < nsamples; i++) {
        float scale = blurStart + (i * precompute);
        color += texture2D(gm_BaseTexture, uv * scale + center);
    }
    
    color /= nsamples;
    
	gl_FragColor = color;
}

