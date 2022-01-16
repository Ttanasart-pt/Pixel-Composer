//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform sampler2D surface;

void main() {
	vec4 zero = vec4(0.);
	vec2 pxPos = v_vTexcoord * vec2(32., 1.);
	
	int amo = 0;
	vec4 list[32];
	
	for(float i = 0.; i <= dimension.x; i++)
	for(float j = 0.; j <= dimension.y; j++) {
		if(amo > 32) break;
		vec4 col = texture2D( surface, vec2(i, j) / dimension );
		
		if(col != zero) {
			bool dup = false;
			
			for(int k = 0; k < amo; k++) {
				if(col == list[k]) {
					dup = true;
					break;
				}
			}
			if(!dup) {
				if(floor(pxPos.x - 1.) == float(amo)) {
					gl_FragColor = col;
					amo = 999;
					break;
				}
				list[amo] = col;
				amo++;
			}
		}
	}
	if(floor(pxPos.x) == 0.)
		gl_FragColor = vec4(float(amo) / 255., 0., 0., 1.);
}
