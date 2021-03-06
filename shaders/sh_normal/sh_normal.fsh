//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform float height;

float bright(in vec4 col) {
	return dot(col.rgb, vec3(0.2126, 0.7152, 0.0722)) * col.a;
}

void main() {
	vec2 pixelStep = 1. / dimension;
    
    float col = texture2D(gm_BaseTexture, v_vTexcoord).r;
    float h0  = texture2D(gm_BaseTexture, v_vTexcoord + pixelStep * vec2(-1., 0.)).r;
    float h1  = texture2D(gm_BaseTexture, v_vTexcoord + pixelStep * vec2( 1., 0.)).r;
    float v0  = texture2D(gm_BaseTexture, v_vTexcoord + pixelStep * vec2(0., -1.)).r;
    float v1  = texture2D(gm_BaseTexture, v_vTexcoord + pixelStep * vec2(0.,  1.)).r;
       
   	vec2 normal = (vec2(h1, v1) - vec2(h0, v0)) / 2. * height + 0.5;
	
    gl_FragColor = vec4(normal, 1., 1.);
}
