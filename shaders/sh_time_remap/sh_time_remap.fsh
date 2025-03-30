//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D map;
uniform float vMin;
uniform float vMax;

float bright(in vec4 col) {
	return dot(col.rgb, vec3(0.2126, 0.7152, 0.0722))  * col.a;
}

void main() {
	float b = bright(texture2D( map, v_vTexcoord ));
	gl_FragColor = vec4(0.);
	
	if(b >= vMin && b <= vMax)
		gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
}
