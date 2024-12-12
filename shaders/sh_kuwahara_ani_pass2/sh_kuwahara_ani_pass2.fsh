#define PI 3.14159265358979323846

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

float gaussian(float sigma, float pos) { return (1.0 / sqrt(2.0 * PI * sigma * sigma)) * exp(-(pos * pos) / (2.0 * sigma * sigma)); }
        
void main() {
	vec2 tx = 1. / dimension;
	int   kernelRadius = 5;
    float kernelSum    = 0.0;
    
    vec4  col = vec4(0.);

    for (int x = -kernelRadius; x <= kernelRadius; ++x) {
        vec4 c = texture2D(gm_BaseTexture, v_vTexcoord + vec2(x, 0.) * tx);
        float gauss = gaussian(2.0, float(x));

        col += c * gauss;
        kernelSum += gauss;
    }

    gl_FragColor = col / kernelSum;
}