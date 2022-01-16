//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

void main() {
	vec4 zero = vec4(0.);
	vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
	
	if(col != zero) {
		vec2 _index_min = v_vTexcoord;
		vec2 _index_max = v_vTexcoord;
	
		for(float i = -1.; i <= 1.; i++)
		for(float j = -1.; j <= 1.; j++) {
			vec4 _col = texture2D( gm_BaseTexture, clamp(v_vTexcoord + vec2(i, j) / dimension, 0., 1.) );
			if(_col != zero) {
				_index_min.x = min(_index_min.x, _col.r);
				_index_min.y = min(_index_min.y, _col.g);
				
				_index_max.x = max(_index_max.x, _col.b);
				_index_max.y = max(_index_max.y, _col.a);
			}
		}
	    gl_FragColor = vec4(_index_min.x, _index_min.y, _index_max.x, _index_max.y );
	}
}
