function draw_line_damping(x0, y0, _w, _h, c0, c1, c2, c3) {
	var SAMPLE = _w;
	
	var _oy;
	for(var i = 0; i <= SAMPLE; i++) {
		var t = i / SAMPLE;
		var _ry = eval_damping(t, c0, c1, c2, c3);
		var _ny = (_h? _ry : 1 - _ry) * abs(_h) + y0;
		
		if(i) draw_line((i - 1) / SAMPLE * _w + x0, _oy, t * _w + x0, _ny);
		_oy = _ny;
	}
}

function eval_damping(t, c0, c1, c2, c3) {
	var pp = 1 + c2;
	var c4 = (2 * pi) / 3;
	var am = c1 * 20;
	
	if(t == 0) return c0;
	if(t == 1) return c3;
	
	return c0 + (power(pp, -am * t) * sin((t * am - 0.75) * c4) + 1) * (c3 - c0);
}

function eval_curve_damping(curve, t) {
	return eval_damping(t, curve[0], curve[1], curve[2], curve[3]);
}

function damp_range(c0, c1, c2, c3) {
	var SAMPLE = 64, minn = 99999, maxx = -99999;
	for(var i = 0; i <= SAMPLE; i++) {
		var t = i / SAMPLE;
		var _ry = eval_damping(t, c0, c1, c2, c3);
		
		minn = min(minn, _ry);
		maxx = max(maxx, _ry);
	}
	
	return [ minn, maxx ];
}

function ease_damp_in(rat, amount) {
	var c1 = amount;
	var c3 = c1 + 1;
	
	return c3 * rat * rat * rat - c1 * rat * rat;
}
function ease_damp_out(rat, amount) {
	var c1 = amount;
	var c3 = c1 + 1;

	return 1 + c3 * power(rat - 1, 3) + c1 * power(rat - 1, 2);
}