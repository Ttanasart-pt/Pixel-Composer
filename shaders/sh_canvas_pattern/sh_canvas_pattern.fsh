varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec4  color;

uniform float seed;

uniform int   empty;
uniform int   pattern;
uniform float pattern_inten;
uniform vec2  pattern_scale;
uniform vec2  pattern_pos;
uniform float pattern_mod;

#define TAU 6.283185307179586

float random (in vec2 st) { return fract(sin(dot(st.xy + seed / 1000., vec2(1892.9898, 78.23453))) * 437.54123); }

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
	vec2 bl = floor(px / vec2(sc.x));
	vec2 ps = mod(px, vec2(sc.x));
	if(mod(bl.x, 2.) < 1.) ps.x = sc.x - ps.x - 1.;
	return abs(ps.x - ps.y) < sc.y / sc.x;
}

bool patHalfZigzag(vec2 rx, vec2 sc) { 
	float thr = dimension.y / 2. - sc.y / 2. + abs(mod(rx.x, sc.x * 2.) - sc.x) * sc.y / sc.x;
	return rx.y > thr; 
}

bool patHalfWave(vec2 rx, vec2 sc) { 
	float thr = dimension.y / 2. + sin(rx.x / dimension.x * sc.x * TAU) * sc.y / 2.;
	return rx.y > thr; 
}

float quant(float v, float stp) { return floor(v * stp + .5) / stp; }

vec4 pbPattern(int pattern, vec2 tx, vec2 pos, vec2 sc, vec4 c0) {
	float dxy = dimension.x + dimension.y;
	vec4  cc  = c0;
	vec4  c1  = mix(c0, color, pattern_inten);
	
	vec2  rx = floor(tx * dimension - pos);
	vec2  px = floor(rx / sc);
	float q = pattern_mod;
	
	     if(pattern == 2) cc = (mod(rx.x, sc.x + sc.y) < sc.y)? c0 : c1;                                          // Stripe X
	else if(pattern == 3) cc = (mod(rx.y, sc.x + sc.y) < sc.y)? c0 : c1;                                          // Stripe Y
	else if(pattern == 4) cc = (mod(rx.x + rx.y, sc.x + sc.y) < sc.y)? c0 : c1;                                   // Stripe D0
	else if(pattern == 5) cc = (mod(rx.x - rx.y, sc.x + sc.y) < sc.y)? c0 : c1;                                   // Stripe D1
	
	else if(pattern == 7) cc = (mod(px.x + px.y, 2.) < 1.)? c0 : c1;                                              // Checker
	else if(pattern == 8) cc = patDiag(rx, sc * 2.)? c0 : c1;                                                     // Checker Diag
	
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
	
	if(pattern < 30) return cc;
	
	     if(pattern == 31) cc = patBrick(rx.xy, sc)? c1 : c0;                                                     // Brick X
	else if(pattern == 32) cc = patBrick(rx.yx, sc)? c1 : c0;                                                     // Brick Y
	
	else if(pattern == 34) cc = patZigzag(rx.xy, sc)? c1 : c0;                                                    // Zigzag X
	else if(pattern == 35) cc = patZigzag(rx.yx, sc)? c1 : c0;                                                    // Zigzag Y
	else if(pattern == 36) cc = patHalfZigzag(rx.xy, sc)? c1 : c0;                                                // Half Zigzag X
	else if(pattern == 37) cc = patHalfZigzag(rx.yx, sc)? c1 : c0;                                                // Half Zigzag Y
	
	else if(pattern == 39) cc = patHalfWave(rx.xy, sc)? c1 : c0;                                                  // Half Wave X
	else if(pattern == 40) cc = patHalfWave(rx.yx, sc)? c1 : c0;                                                  // Half Wave Y
	
	else if(pattern == 42) cc = random(px.xy) < pattern_inten? color : c0;                                        // Noise
	
	return cc;
}

void main() {
	vec4 cc = vec4(0.);
	
	if(empty == 0) {
		cc = texture2D(gm_BaseTexture, v_vTexcoord);
		gl_FragColor = cc;
		if(cc.a == 0.) return;
	}
	
	vec4 cs = pbPattern(pattern, v_vTexcoord, pattern_pos, pattern_scale, cc);
	gl_FragColor = cs;
}