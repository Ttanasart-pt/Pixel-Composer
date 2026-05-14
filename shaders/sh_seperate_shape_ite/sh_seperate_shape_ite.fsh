varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float threshold;
uniform int   ignore;
uniform int   mode;
uniform int   diagonal;
uniform sampler2D map;

vec4  sampVal( vec4 col) { return mode == 1? vec4(col.a) : col; }
float sampValf(vec4 col) { return mode == 1? col.a : length(col.rgb) * col.a; }

void main() {
	vec4 baseCol   = texture2D( map, v_vTexcoord );
	vec4 baseVal   = sampVal(baseCol);
	bool selfblank = sampValf(baseCol) == 0.;
	
	gl_FragColor = vec4(0.);
	if(ignore == 1 && selfblank) return;
	
	vec2 tx = 1. / dimension;
	vec4 _c = texture2D( gm_BaseTexture, v_vTexcoord );
	vec2 _index_min = _c.xy;
	vec2 _index_max = _c.zw;
	
	for(float i = -1.; i <= 1.; i++)
	for(float j = -1.; j <= 1.; j++) {
		if(i == 0. && j == 0.) continue;
		if(diagonal == 0 && abs(i) + abs(j) > 1.) continue;
		
		vec2 pos   = clamp(v_vTexcoord + vec2(i, j) * tx, 0., 1.);
		vec4 samCl = texture2D( map, pos );
		bool blank = sampValf(samCl) == 0.;
		if(ignore == 1 && blank) continue;
		
		bool spread = false;
		
		if(ignore != 2) {
			spread = distance(sampVal(samCl), baseVal) <= threshold;
			
		} else {
			if( selfblank && !blank) spread = true;
			if(!selfblank &&  blank) spread = true;
			if(!selfblank && !blank) spread = distance(sampVal(samCl), baseVal) <= threshold;
		}
		
		if(spread) {
			vec4 _col = texture2D( gm_BaseTexture, pos );
			_index_min.x = min(_index_min.x, _col.r);
			_index_min.y = min(_index_min.y, _col.g);
				
			_index_max.x = max(_index_max.x, _col.b);
			_index_max.y = max(_index_max.y, _col.a);
		}
	}
	
	gl_FragColor = vec4( _index_min, _index_max );
}
