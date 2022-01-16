//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

void main() {
	vec2 _index = v_vTexcoord;
	
	vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
	float bright = dot(col.rgb, vec3(0.2126, 0.7152, 0.0722));
	
	if(col.a > 0. && bright > 0.) {
		for(float i = -1.; i <= 1.; i++)
		for(float j = -1.; j <= 1.; j++) {
			vec4 _col = texture2D( gm_BaseTexture, v_vTexcoord + vec2(i, j) / dimension );
			float _bright = dot(_col.rgb, vec3(0.2126, 0.7152, 0.0722));
			if(_col.a > 0. && abs(bright - _bright) < 0.1) {
				_index.x = min(_index.x, _col.r);
				_index.y = min(_index.y, _col.g);
			}
		}
	    gl_FragColor = vec4(_index, 1., 1.);
	} else {
		gl_FragColor = vec4(0.);	
	}
}
