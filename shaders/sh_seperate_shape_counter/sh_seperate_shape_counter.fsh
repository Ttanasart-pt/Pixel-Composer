varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform sampler2D surface;
uniform int maxShape;
uniform int ignore;

void main() {
	vec4 zero  = vec4(0.);
	vec2 pxPos = v_vTexcoord * vec2(float(maxShape), 1.) - 0.5;
	
	int amo = 0;
	vec4 list[1024];
	
	for(float i = 0.; i <= dimension.x; i++)
	for(float j = 0.; j <= dimension.y; j++) {
		if(amo > maxShape) break;
		
		vec4 col = texture2D( surface, vec2(i, j) / dimension );
		if(ignore == 1 && col == zero) continue;
		
		bool dup = false;	
		for(int k = 0; k < amo; k++) {
			if(col == list[k]) {
				dup = true;
				break;
			}
		}
		
		if(dup) continue;
		
		if(floor(pxPos.x - 1.) == float(amo)) {
			gl_FragColor = col;
			return;
		}
		list[amo] = col;
		amo++;
	}
	
	if(floor(pxPos.x) == 0.) gl_FragColor = vec4(amo, 0., 0., 0.);
}
