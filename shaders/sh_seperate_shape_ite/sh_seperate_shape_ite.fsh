//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform float threshold;
uniform int ignore;
uniform sampler2D map;

vec3 sampVal(vec4 col) { return col.rgb * col.a; }

void main() {
	vec4 zero = vec4(0.);
	vec3 baseCol = sampVal(texture2D( map, v_vTexcoord ));
	
	if(ignore == 1 && baseCol == 0.) {
		gl_FragColor = vec4(0.);
		return;
	}
	
	vec2 _index_min = v_vTexcoord;
	vec2 _index_max = v_vTexcoord;
	
	for(float i = -1.; i <= 1.; i++)
	for(float j = -1.; j <= 1.; j++) {
		vec2 pos = clamp(v_vTexcoord + vec2(i, j) / dimension, 0., 1.);
		vec3 samCl = sampVal(texture2D( map, pos ));
		
		if(ignore == 1 && samCl == 0.)
			continue;
		
		if(distance(samCl, baseCol) <= threshold) {
			vec4 _col = texture2D( gm_BaseTexture, pos );
			_index_min.x = min(_index_min.x, _col.r);
			_index_min.y = min(_index_min.y, _col.g);
				
			_index_max.x = max(_index_max.x, _col.b);
			_index_max.y = max(_index_max.y, _col.a);
		}
	}
	gl_FragColor = vec4(_index_min.x, _index_min.y, _index_max.x, _index_max.y );
}
