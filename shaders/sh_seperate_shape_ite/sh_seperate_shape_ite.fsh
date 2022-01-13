//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

void main() {
	vec2 _index = v_vTexcoord;
	
	vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
	if(col.a > 0.) {
		for(float i = -1.; i <= 1.; i++)
		for(float j = -1.; j <= 1.; j++) {
			vec4 _col = texture2D( gm_BaseTexture, v_vTexcoord + vec2(i, j) / dimension );
			if(_col.a > 0. && _col.b == col.b) {
				_index.x = min(_index.x, _col.r);
				_index.y = min(_index.y, _col.g);
			}
		}
	    gl_FragColor = vec4(_index, 1., 1.);
	} else {
		gl_FragColor = vec4(0.);	
	}
}
