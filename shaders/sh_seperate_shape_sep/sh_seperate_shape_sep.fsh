//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D original;
uniform vec2 color;

void main() {
    vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
	
	if(distance(col.rg * 255., color) < 1.) {
		gl_FragColor = texture2D( original, v_vTexcoord );
	} else 
		gl_FragColor = vec4(0.);
}
