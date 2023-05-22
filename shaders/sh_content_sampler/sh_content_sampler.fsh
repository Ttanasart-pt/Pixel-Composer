//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 sampler;

void main() {
	vec2 pos = floor((v_vTexcoord * dimension) / sampler) * sampler;
	pos /= dimension;
	
	gl_FragColor = vec4(0.);
	
	for(float i = 0.; i <= sampler.x; i++)
	for(float j = 0.; j <= sampler.y; j++) {
		vec4 col = texture2D( gm_BaseTexture, pos + vec2(i, j) / dimension);
		if(col.a > 0.) {
			gl_FragColor = vec4(1.);
			return;
		}
	}
}
