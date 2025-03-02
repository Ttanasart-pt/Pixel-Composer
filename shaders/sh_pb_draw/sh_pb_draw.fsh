varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;

uniform int   fill;
uniform vec4  fill_color;
uniform int   fill_pattern;
uniform vec2  fill_pattern_scale;
uniform vec4  fill_pattern_color;
uniform float fill_pattern_inten;

uniform int   stroke;
uniform float stroke_thickness;
uniform vec4  stroke_color;
uniform int   stroke_position;
uniform int   stroke_corner;
uniform int   stroke_pattern;
uniform vec2  stroke_pattern_scale;
uniform vec4  stroke_pattern_color;
uniform float stroke_pattern_inten;

uniform int   corner;
uniform float corner_radius;
uniform vec4  corner_color;
uniform int   corner_effect;
uniform int   corner_subtract;

uniform int   highlight;
uniform vec4  highlight_width;
uniform vec4  highlight_l;
uniform vec4  highlight_r;
uniform vec4  highlight_t;
uniform vec4  highlight_b;

void main() {
	vec2 tx = 1. / dimension;
	vec2 px;
	vec4 c0, c1;
	
	vec4 shapeMask = texture2D(gm_BaseTexture, v_vTexcoord);
	bool isShape   = shapeMask.a > 0.;
	
	vec4 cc = vec4(0.);
	
	if(fill == 1 && isShape) {
		px = floor(v_vTexcoord * dimension / fill_pattern_scale);
		c0 = fill_color;
		c1 = mix(fill_color, fill_pattern_color, fill_pattern_inten);
		cc = c0;
		
		     if(fill_pattern == 1) cc = (mod(px.x, 2.) == 0.)? c0 : c1;                         // Stripe X
		else if(fill_pattern == 2) cc = (mod(px.y, 2.) == 0.)? c0 : c1;                         // Stripe Y
		else if(fill_pattern == 3) cc = (mod(px.x + px.y, 2.) == 0.)? c0 : c1;                  // Checker
		else if(fill_pattern == 4) cc = (mod(px.x, 2.) == 0. && mod(px.y, 2.) == 0.)? c0 : c1;  // Dotted
	}
	
	if(highlight == 1 && isShape) {
		int   high = -1;
		float dist = 9999.;
		
		for(float i = 1.; i <= highlight_width[2]; i++) {
			vec4 samp = texture2D(gm_BaseTexture, v_vTexcoord + vec2(-1., 0.) * i * tx);
			if(samp.a == 0.) { if(i < dist) { dist = i; high = 0; } break; }
		}
		
		for(float i = 1.; i <= highlight_width[0]; i++) {
			vec4 samp = texture2D(gm_BaseTexture, v_vTexcoord + vec2( 1., 0.) * i * tx);
			if(samp.a == 0.) { if(i < dist) { dist = i; high = 1; } break; }
		}
		
		for(float i = 1.; i <= highlight_width[1]; i++) {
			vec4 samp = texture2D(gm_BaseTexture, v_vTexcoord + vec2(0., -1.) * i * tx);
			if(samp.a == 0.) { if(i < dist) { dist = i; high = 2; } break; }
		}
		
		for(float i = 1.; i <= highlight_width[3]; i++) {
			vec4 samp = texture2D(gm_BaseTexture, v_vTexcoord + vec2(0.,  1.) * i * tx);
			if(samp.a == 0.) { if(i < dist) { dist = i; high = 3; } break; }
		}
		
		     if(high == 0) cc = highlight_l;
		else if(high == 1) cc = highlight_r;
		else if(high == 2) cc = highlight_t;
		else if(high == 3) cc = highlight_b;
	}
	
	float kfill = 0.;
	float ksize = 0.;
	float borDist = 99999.;
	float borCond = isShape? 0. : 1.;
	float scanRad = max(corner_radius, stroke_thickness);
	
	for(float i = -scanRad; i <= scanRad; i++)
	for(float j = -scanRad; j <= scanRad; j++) {
		vec4 samp = texture2D(gm_BaseTexture, v_vTexcoord + vec2(i, j) * tx);
		
		if(abs(i) <= corner_radius && abs(j) <= corner_radius) {
			ksize++;
			kfill += samp.a;
		}
		
		if(abs(i) <= stroke_thickness && abs(j) <= stroke_thickness) {
			if(samp.a == borCond) borDist = min(borDist, stroke_corner == 0? length(vec2(i, j)) : min(i, j));
		}
	}
	
	bool isStroke = false;
	
	if(stroke == 1) {
		     if(stroke_position == 0) isStroke =             borDist <= float(stroke_thickness) / 2.;
		else if(stroke_position == 1) isStroke =  isShape && borDist <= float(stroke_thickness);
		else if(stroke_position == 2) isStroke = !isShape && borDist <= float(stroke_thickness);
		
		if(isStroke) {
			px = floor(v_vTexcoord * dimension / stroke_pattern_scale);
			c0 = stroke_color;
			c1 = mix(stroke_color, stroke_pattern_color, stroke_pattern_inten);
			cc = c0;
			
			     if(stroke_pattern == 1) cc = (mod(px.x, 2.) == 0.)? c0 : c1;                         // Stripe X
			else if(stroke_pattern == 2) cc = (mod(px.y, 2.) == 0.)? c0 : c1;                         // Stripe Y
			else if(stroke_pattern == 3) cc = (mod(px.x + px.y, 2.) == 0.)? c0 : c1;                  // Checker
			else if(stroke_pattern == 4) cc = (mod(floor(borDist), 2.) == 0.)? c0 : c1;               // Layered
		}
	}
	
	if(corner == 1) {
		bool isCorner = isShape && (kfill / ksize) < .5;
		vec4 crn_col = corner_subtract == 1? vec4(0.) : corner_color;
		
		if(isCorner) {
			     if(corner_effect == 0)             cc = crn_col;
			else if(corner_effect == 1 && isStroke) cc = crn_col;
		}
		
	}
	
	gl_FragColor = cc;
}