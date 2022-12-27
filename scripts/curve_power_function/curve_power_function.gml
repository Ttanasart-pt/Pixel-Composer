function draw_line_power(x0, y0, _w, _h, c0, c1, c2, c3) {
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

function ease_power_in(rat, pow) {
	return power(rat, pow);
}
function ease_power_out(rat, pow) {
	return 1 - power(1 - rat, pow);
}
function ease_power_inout(rat, pow) {
	return rat < 0.5 ? ease_power_in(2 * rat, pow) / 2 : (ease_power_out(2 * rat - 1, pow) + 1) / 2;
}