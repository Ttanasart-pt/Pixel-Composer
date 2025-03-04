varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec4  bbox;

uniform int   fill;
uniform vec4  fill_color;
uniform int   fill_pattern;
uniform vec2  fill_pattern_pos;
uniform vec2  fill_pattern_scale;
uniform int   fill_pattern_map;
uniform vec4  fill_pattern_color;
uniform float fill_pattern_inten;

uniform int   stroke;
uniform float stroke_thickness;
uniform vec4  stroke_color;
uniform int   stroke_position;
uniform int   stroke_corner;
uniform int   stroke_pattern;
uniform vec2  stroke_pattern_pos;
uniform vec2  stroke_pattern_scale;
uniform int   stroke_pattern_map;
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

#define TAU 6.283185307179586

bool patDiag(vec2 px, vec2 sc) {
	vec2 _px = mod(px, sc + 1.);
	
	bool d1 = _px.x > _px.y;
	bool d2 = (sc.x - _px.x) > _px.y;
	bool chk = (d1 && d2) || (!d1 && !d2);
	
	return chk;
}

bool patGrid(vec2 px, vec2 sc) { return mod(px.x, sc.x + 1.) < 1. || mod(px.y, sc.y + 1.) < 1.; }

bool patGridDiag(vec2 px, vec2 sc) {
	vec2 _px = mod(px, sc);
	
	bool d1 = abs(_px.x - _px.y) < 1.;
	bool d2 = abs(_px.x - (sc.x - 2. - _px.y)) < 1.;
	bool chk = d1 || d2;
	
	return chk;
}

bool patBrick(vec2 px, vec2 sc) { return (mod(px.x + mod(floor(px.y / (sc.y + 1.)), 2.) * sc.x, sc.x * 2. + 1.) < 1.) || mod(px.y, sc.y + 1.) < 1.; }

bool patZigzag(vec2 px, vec2 sc) { 
	vec2 bl = floor(px / sc);
	vec2 ps = mod(px, sc);
	if(mod(bl.x, 2.) < 1.) ps.x = sc.x - ps.x - 1.;
	return ps.x == ps.y;
}

vec4 pbPattern(int pattern, vec2 tx, vec2 pos, vec2 sc, vec4 c0, vec4 c1) {
	float dxy = dimension.x + dimension.y;
	vec4  cc  = c0;
	
	vec2  rx = floor(tx * dimension - pos);
	vec2  px = floor(rx / sc);
	
	     if(pattern == 2) cc = (mod(rx.x, sc.x + sc.y) < sc.y)? c0 : c1;                                          // Stripe X
	else if(pattern == 3) cc = (mod(rx.y, sc.x + sc.y) < sc.y)? c0 : c1;                                          // Stripe Y
	else if(pattern == 4) cc = (mod(rx.x + rx.y, sc.x + sc.y) < sc.y)? c0 : c1;                                   // Stripe D0
	else if(pattern == 5) cc = (mod(rx.x - rx.y, sc.x + sc.y) < sc.y)? c0 : c1;                                   // Stripe D1
	
	else if(pattern == 7) cc = (mod(px.x + px.y, 2.) < 1.)? c0 : c1;                                              // Checker
	else if(pattern == 8) cc = patDiag(rx, sc)? c0 : c1;                                                          // Checker Diag
	
	else if(pattern == 10) cc = patGrid(rx, sc)? c1 : c0;                                                         // Grid
	else if(pattern == 11) cc = patGridDiag(rx, sc)? c1 : c0;                                                     // Grid Diag
	
	else if(pattern == 13) cc = (rx.y >= dimension.y / 2.)?                c1 : c0;                               // Half X
	else if(pattern == 14) cc = (rx.x >= dimension.x / 2.)?                c1 : c0;                               // Half Y
	else if(pattern == 15) cc = (rx.x + px.y >= dxy / 2.)?                 c1 : c0;                               // Half D0
	else if(pattern == 16) cc = (rx.x + (dimension.x - px.y) >= dxy / 2.)? c1 : c0;                               // Half D1
	
	else if(pattern == 18) cc = mix(c0, c1, clamp(px.x / dimension.x, 0., 1.));                                   // Gradient X
	else if(pattern == 19) cc = mix(c0, c1, clamp(px.y / dimension.y, 0., 1.));                                   // Gradient Y
	else if(pattern == 20) cc = mix(c0, c1, clamp((px.x + px.y) / dxy, 0., 1.));                                  // Gradient D0
	else if(pattern == 21) cc = mix(c0, c1, clamp((px.x + (dimension.x - px.y)) / dxy, 0., 1.));                  // Gradient D1
	
	else if(pattern == 23) cc = mix(c0, c1, (abs(clamp(px.x / dimension.x, 0., 1.) - .5) * 2.));                  // Gradient2 X
	else if(pattern == 24) cc = mix(c0, c1, (abs(clamp(px.y / dimension.y, 0., 1.) - .5) * 2.));                  // Gradient2 Y
	else if(pattern == 25) cc = mix(c0, c1, (abs(clamp((px.x + px.y) / dxy, 0., 1.) - .5) * 2.));                 // Gradient2 D0
	else if(pattern == 26) cc = mix(c0, c1, (abs(clamp((px.x + (dimension.x - px.y)) / dxy, 0., 1.) - .5) * 2.)); // Gradient2 D1
	
	else if(pattern == 28) cc = mix(c1, c0, sqrt(pow(tx.x - pos.x - .5, 2.) / sc.x + 
	                                             pow(tx.y - pos.y - .5, 2.) / sc.y) * 2.);                        // Gradient Circular
	else if(pattern == 29) {                                                                                      // Gradient Radial
		vec2  _v = (tx - pos - .5) / sc;
		float _a = atan(_v.y, _v.x);
		_a = (_a - floor(_a / TAU) * TAU) / TAU;
		cc = mix(c0, c1, _a); 
	}
	
	else if(pattern == 31) cc = patBrick(rx.xy, sc)? c1 : c0;                                                     // Brick X
	else if(pattern == 32) cc = patBrick(rx.yx, sc)? c1 : c0;                                                     // Brick Y
	
	else if(pattern == 34) cc = patZigzag(rx.xy, sc)? c1 : c0;                                                    // Zigzag X
	else if(pattern == 35) cc = patZigzag(rx.yx, sc)? c1 : c0;                                                    // Zigzag Y
	
	return cc;
}

vec4 sampleTex(vec2 px) {
	if(px.x < 0. || px.y < 0. || px.x > 1. || px.y > 1.) return vec4(0.);
	return texture2D(gm_BaseTexture, px);
}

void main() {
	vec2 tx     = 1. / dimension;
	vec4 bboxtx = bbox * vec4(tx, tx);
	vec2 txMap  = (v_vTexcoord - bboxtx.xy) / (bboxtx.zw - bboxtx.xy);
	
	vec2 px, rx;
	vec4 c0, c1;
		
	vec4 shapeMask = sampleTex(v_vTexcoord);
	bool isShape   = shapeMask.a > 0.;
	
	vec4 cc = vec4(0.);
	
	if(fill == 1 && isShape) {
		c0 = fill_color;
		c1 = mix(fill_color, fill_pattern_color, fill_pattern_inten);
		cc = pbPattern(fill_pattern, fill_pattern_map == 1? txMap : v_vTexcoord, fill_pattern_pos, fill_pattern_scale, c0, c1);
	}
	
	if(highlight == 1 && isShape) {
		int   high = -1;
		float dist = 9999.;
		
		for(float i = 1.; i <= highlight_width[2]; i++) {
			vec4 samp = sampleTex(v_vTexcoord + vec2(-1., 0.) * i * tx);
			if(samp.a == 0.) { if(i < dist) { dist = i; high = 0; } break; }
		}
		
		for(float i = 1.; i <= highlight_width[0]; i++) {
			vec4 samp = sampleTex(v_vTexcoord + vec2( 1., 0.) * i * tx);
			if(samp.a == 0.) { if(i < dist) { dist = i; high = 1; } break; }
		}
		
		for(float i = 1.; i <= highlight_width[1]; i++) {
			vec4 samp = sampleTex(v_vTexcoord + vec2(0., -1.) * i * tx);
			if(samp.a == 0.) { if(i < dist) { dist = i; high = 2; } break; }
		}
		
		for(float i = 1.; i <= highlight_width[3]; i++) {
			vec4 samp = sampleTex(v_vTexcoord + vec2(0.,  1.) * i * tx);
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
		vec4 samp = sampleTex(v_vTexcoord + vec2(i, j) * tx);
		
		if(abs(i) <= corner_radius && abs(j) <= corner_radius) {
			ksize++;
			kfill += samp.a;
		}
		
		if(abs(i) <= stroke_thickness && abs(j) <= stroke_thickness) {
			if(samp.a == borCond) {
				
				borDist = min(borDist, stroke_corner == 0? length(vec2(i, j)) : min(i, j));
			}
		}
	}
	
	bool isStroke = false;
	
	if(stroke == 1) {
		     if(stroke_position == 0) isStroke =             borDist <= float(stroke_thickness) / 2.;
		else if(stroke_position == 1) isStroke =  isShape && borDist <= float(stroke_thickness);
		else if(stroke_position == 2) isStroke = !isShape && borDist <= float(stroke_thickness);
		
		if(isStroke) {
			c0 = stroke_color;
			c1 = mix(stroke_color, stroke_pattern_color, stroke_pattern_inten);
			cc = pbPattern(stroke_pattern, stroke_pattern_map == 1? txMap : v_vTexcoord, stroke_pattern_pos, stroke_pattern_scale, c0, c1);
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