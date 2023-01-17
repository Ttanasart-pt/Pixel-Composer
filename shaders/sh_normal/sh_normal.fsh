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
    
	vec4 c = texture2D(gm_BaseTexture, v_vTexcoord);
    float col = bright(c);
    float h0  = bright(texture2D(gm_BaseTexture, v_vTexcoord + pixelStep * vec2(-1., 0.)));
    float h1  = bright(texture2D(gm_BaseTexture, v_vTexcoord + pixelStep * vec2( 1., 0.)));
    float v0  = bright(texture2D(gm_BaseTexture, v_vTexcoord + pixelStep * vec2(0., -1.)));
    float v1  = bright(texture2D(gm_BaseTexture, v_vTexcoord + pixelStep * vec2(0.,  1.)));
       
   	vec2 normal = (vec2(h1, v1) - vec2(h0, v0)) / 2. * height + 0.5;
	
    gl_FragColor = vec4(normal, 1., c.a);
}
