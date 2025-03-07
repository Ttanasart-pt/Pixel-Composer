varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec4  bbox;

uniform int   type;
uniform vec4  color;
uniform float intensity;
uniform int   empty;
uniform int   subtract;

uniform int   pattern;
uniform vec4  pattern_color;
uniform float pattern_inten;
uniform vec2  pattern_scale;
uniform vec2  pattern_pos;
uniform int   pattern_map;
uniform float pattern_mod;

uniform float stroke_thickness;
uniform int   stroke_position;
uniform int   stroke_corner;

uniform float corner_radius;

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

float quant(float v, float stp) { return floor(v * stp + .5) / stp; }

vec4 pbPattern(int pattern, vec2 tx, vec2 pos, vec2 sc, vec4 c0) {
	float dxy = dimension.x + dimension.y;
	vec4  cc  = c0;
	vec4  c1  = mix(c0, pattern_color, pattern_inten);
	
	vec2  rx = floor(tx * dimension - pos);
	vec2  px = floor(rx / sc);
	float q = pattern_mod;
	
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
	
	else if(pattern == 18) cc = mix(c0, c1, quant(clamp(px.x / dimension.x, 0., 1.), q));                         // Gradient X
	else if(pattern == 19) cc = mix(c0, c1, quant(clamp(px.y / dimension.y, 0., 1.), q));                         // Gradient Y
	else if(pattern == 20) cc = mix(c0, c1, quant(clamp((px.x + px.y) / dxy, 0., 1.), q));                        // Gradient D0
	else if(pattern == 21) cc = mix(c0, c1, quant(clamp((px.x + (dimension.x - px.y)) / dxy, 0., 1.), q));        // Gradient D1
	
	else if(pattern == 23) cc = mix(c0, c1, quant(abs(clamp(px.x / dimension.x, 0., 1.) - .5) * 2., q));                   // Gradient2 X
	else if(pattern == 24) cc = mix(c0, c1, quant(abs(clamp(px.y / dimension.y, 0., 1.) - .5) * 2., q));                   // Gradient2 Y
	else if(pattern == 25) cc = mix(c0, c1, quant(abs(clamp((px.x + px.y) / dxy, 0., 1.) - .5) * 2., q));                  // Gradient2 D0
	else if(pattern == 26) cc = mix(c0, c1, quant(abs(clamp((px.x + (dimension.x - px.y)) / dxy, 0., 1.) - .5) * 2., q));  // Gradient2 D1
	
	else if(pattern == 28) cc = mix(c1, c0, quant(sqrt(pow(tx.x - pos.x - .5, 2.) / sc.x + 
	                                                   pow(tx.y - pos.y - .5, 2.) / sc.y) * 2., q));              // Gradient Circular
	else if(pattern == 29) {                                                                                      // Gradient Radial
		vec2  _v = (tx - pos - .5) / sc;
		float _a = atan(_v.y, _v.x);
		_a = (_a - floor(_a / TAU) * TAU) / TAU;
		cc = mix(c0, c1, quant(_a, 4.)); 
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

vec4 mmix(vec4 c0, vec4 c1, float inten) { return subtract == 0? mix(c0, c1, c1.a * inten) : vec4(c0.rgb, c0.a - inten); }

void main() {
	vec2 tx     = 1. / dimension;
	vec4 bboxtx = bbox * vec4(tx, tx);
	vec2 txMap  = (v_vTexcoord - bboxtx.xy) / (bboxtx.zw - bboxtx.xy);
	
	vec4 cc      = sampleTex(v_vTexcoord);
	gl_FragColor = empty == 1? vec4(0.) : cc;
	
	bool isShape = cc.a > 0.;
	vec2 patx    = pattern_map == 1? txMap : v_vTexcoord;
	vec4 cs      = pbPattern(pattern, patx, pattern_pos, pattern_scale, color);
	
	if(type == 0) { // fill
		if(isShape) gl_FragColor = mmix(cc, cs, intensity);
		return;
	}
	
	if(type == 1) { // stroke
		float borDist = 99999.;
		float borCond = isShape? 0. : 1.;
		
		for(float i = -stroke_thickness; i <= stroke_thickness; i++)
		for(float j = -stroke_thickness; j <= stroke_thickness; j++) {
			vec4 samp = sampleTex(v_vTexcoord + vec2(i, j) * tx);
			
			if(samp.a == borCond)
				borDist = min(borDist, stroke_corner == 0? length(vec2(i, j)) : min(i, j));
		}
		
		bool isStroke = false;
		
		     if(stroke_position == 0) isStroke =             borDist <= float(stroke_thickness) / 2.;
		else if(stroke_position == 1) isStroke =  isShape && borDist <= float(stroke_thickness);
		else if(stroke_position == 2) isStroke = !isShape && borDist <= float(stroke_thickness);
		
		if(isStroke) gl_FragColor = mmix(cc, cs, intensity);
		return;
	}
	
	if(type == 2) { // corner
			
		float kfill = 0.;
		float ksize = 0.;
		
		for(float i = -corner_radius; i <= corner_radius; i++)
		for(float j = -corner_radius; j <= corner_radius; j++) {
			vec4 samp = sampleTex(v_vTexcoord + vec2(i, j) * tx);
			
			ksize++;
			kfill += samp.a;
		}
		
		bool isCorner = isShape && (kfill / ksize) < .5;
		if(isCorner) gl_FragColor = mmix(cc, cs, intensity);
		return;
	}
	
	if(type == 3) { // highlight
		if(isShape) {
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
			
			     if(high == 0) gl_FragColor = mmix(cc, pbPattern(pattern, patx, pattern_pos, pattern_scale, highlight_l), intensity);
			else if(high == 1) gl_FragColor = mmix(cc, pbPattern(pattern, patx, pattern_pos, pattern_scale, highlight_r), intensity);
			else if(high == 2) gl_FragColor = mmix(cc, pbPattern(pattern, patx, pattern_pos, pattern_scale, highlight_t), intensity);
			else if(high == 3) gl_FragColor = mmix(cc, pbPattern(pattern, patx, pattern_pos, pattern_scale, highlight_b), intensity);
			
		}
		
		return;
	}
	
}