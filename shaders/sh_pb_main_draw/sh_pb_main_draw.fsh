varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;

uniform int   stroke;
uniform float stroke_thickness;
uniform vec4  stroke_color;

uniform float corner_radius;

void main() {
	vec2 tx = 1. / dimension;
	vec4 cc = texture2D(gm_BaseTexture, v_vTexcoord);
	
	gl_FragColor = cc;
	if(cc.a == 1.) return;
	
	float borDist = 99999.;
	
	for(float i = -16.; i <= 16.; i++)
	for(float j = -16.; j <= 16.; j++) {
		if(abs(i) > stroke_thickness || abs(j) > stroke_thickness) continue;
		vec4 samp = texture2D(gm_BaseTexture, v_vTexcoord + vec2(i, j) * tx);
		
		if(abs(i) <= stroke_thickness && abs(j) <= stroke_thickness) {
			if(samp.a == 1.) borDist = min(borDist, length(vec2(i, j)));
		}
	}
	
	if(stroke == 1) {
		if(borDist <= float(stroke_thickness))
			gl_FragColor = stroke_color;
	}
	
}