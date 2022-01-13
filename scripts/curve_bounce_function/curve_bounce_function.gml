function draw_line_bounce(x0, y0, _w, _h, c0, c1, c2, c3) {
	var SAMPLE = _w;
	
	var _oy;
	for(var i = 0; i <= SAMPLE; i++) {
		var t = i / SAMPLE;
		var _ry = eval_bounce(t, c0, c1, c2, c3);
		var _ny = (_h? _ry : 1 - _ry) * abs(_h) + y0;
		
		if(i) draw_line((i - 1) / SAMPLE * _w + x0, _oy, t * _w + x0, _ny);
		_oy = _ny;
	}
}

function eval_bounce(t, c0, c1, c2, c3) {
	var amplitude	= 1;
	var len			= c1;
	var damp		= c2;
	var prev_bounce = -len / 2;
	var next_bounce = prev_bounce;
	
	var bounce = 1;
	var max_bounce = 10;
	
	while(1) {
		prev_bounce = next_bounce;
		next_bounce = min(next_bounce + len, 1);
		
		if(next_bounce > t) break;
		if(++bounce > max_bounce) break;
		
		amplitude *= damp;
		len *= damp;
	}
	
	if(bounce > max_bounce) return 1;
	
	len = next_bounce - prev_bounce;
	var phase	= t - prev_bounce;
	var range   = c3 - c0;
	var val		= c0 + (1 - sin(phase / len * pi) * amplitude) * range;
	
	return val;
}

function eval_curve_bounce(curve, t) {
	return eval_bounce(t, curve[0], curve[1], curve[2], curve[3]);
}

function bounce_range(c0, c1, c2, c3) {
	return [ min(c0, c1, c2, c3), max(c0, c1, c2, c3) ];
}