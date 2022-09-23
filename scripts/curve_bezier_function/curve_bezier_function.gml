function draw_line_bezier_cubic(x0, y0, _w, _h, c0, c1, c2, c3) {
	static SAMPLE = 32;
	
	var _oy;
	for(var i = 0; i <= SAMPLE; i++) {
		var t = i / SAMPLE;
		var _ry = eval_bezier_cubic(t, c0, c1, c2, c3);
		var _ny = (_h? _ry : 1 - _ry) * abs(_h) + y0;
		
		if(i) draw_line((i - 1) / SAMPLE * _w + x0, _oy, t * _w + x0, _ny);
		_oy = _ny;
	}
}

function eval_bezier_cubic(t, c0, c1, c2, c3) {
	return power(1 - t, 3) * c0 + 3 * power(1 - t, 2) * t * c1 + 3 * (1 - t) * power(t, 2) * c2 + power(t, 3) * c3;
}

function eval_curve_bezier_cubic(curve, t) {
	return eval_bezier_cubic(t, curve[0], curve[1], curve[2], curve[3]);
}

function bezier_range(c0, c1, c2, c3) {
	return [ min(c0, c1, c2, c3), max(c0, c1, c2, c3) ];
}

function bezier_interpol_x(a, b, t, iteration = 16) {
	var fx, _x = 0.5, _x1, slope;
	repeat(iteration) {
		fx = (3 * a - 3 * b + 1) * _x * _x * _x
			+ (3 * b - 6 * a) * _x * _x
			+ 3 * a * _x
			- t;
		slope = 3 * (3 * a - 3 * b + 1) * _x * _x
			+ 2 * (3 * b - 6 * a) * _x
			+ 3 * a;
				
		_x -= fx / slope;
	}
			
	return 3 * (1 - _x) * _x * _x + _x * _x * _x;
}

function ease_cubic_in(rat) {
	return rat * rat * rat;
}
function ease_cubic_out(rat) {
	return 1 - power(1 - rat, 3);
}
function ease_cubic_inout(rat) {
	return rat < 0.5 ? 4 * power(rat, 3) : 1 - power(-2 * rat + 2, 3) / 2;
}