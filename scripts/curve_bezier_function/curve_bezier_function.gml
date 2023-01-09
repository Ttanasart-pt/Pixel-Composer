#macro CURVE_DEF_01 [0, 1/3, 1/3, 2/3, 2/3, 1]
#macro CURVE_DEF_11 [1, 1/3,   1, 2/3,   1, 1]

function draw_line_bezier_cubic(x0, y0, _w, _h, _bz) {
	static SAMPLE = 32;
	
	var _ox, _oy;
	
	for(var i = 0; i <= SAMPLE; i++) {
		var t = i / SAMPLE;
		var _r  = eval_bezier_cubic(t, _bz);
		var _rx = _r[0], _ry = _r[1];
		
		var _nx = _rx * _w + x0;
		var _ny = (_h? _ry : 1 - _ry) * abs(_h) + y0;
		
		if(i) 
			draw_line(_ox, _oy, _nx, _ny);
		
		_ox = _nx;
		_oy = _ny;
	}
}

function eval_bezier_cubic(t, _bz) {
	return [ 
		       power(1 - t, 3) * 0 
			 + 3 * power(1 - t, 2) * t * _bz[1] 
			 + 3 * (1 - t) * power(t, 2) * _bz[3]
			 + power(t, 3) * 1, 
			 
			   power(1 - t, 3) * _bz[0]
			 + 3 * power(1 - t, 2) * t * _bz[2] 
			 + 3 * (1 - t) * power(t, 2) * _bz[4]
			 + power(t, 3) * _bz[5]
		];
}

function eval_curve_bezier_cubic_x(_bz, _x, _prec = 0.00001) {
	var st = 0;
	var ed = 1;
	
	var _xt = _x;
	var _binRep = 5;
	
	repeat(_binRep) {
		var _ftx = power(1 - _xt, 3) * 0 
			 + 3 * power(1 - _xt, 2) * _xt * _bz[1] 
			 + 3 * (1 - _xt) * power(_xt, 2) * _bz[3]
			 + power(_xt, 3) * 1;
		
		if(abs(_ftx - _x) < _prec)
			return eval_curve_bezier_cubic_t(_bz, _xt);
		
		if(_xt < _x)
			st = _xt;
		else
			ed = _xt;
		
		_xt = (st + ed) / 2;
	}
	
	var _newRep = 8;
	
	repeat(_newRep) {
		var slope =   (9 * _bz[1] - 9 * _bz[3] + 3) * _xt * _xt
					+ (-12 * _bz[1] + 6 * _bz[3]) * _xt
					+ 3 * _bz[1];
		var _ftx = power(1 - _xt, 3) * 0 
				 + 3 * power(1 - _xt, 2) * _xt * _bz[1] 
				 + 3 * (1 - _xt) * power(_xt, 2) * _bz[3]
				 + power(_xt, 3) * 1
				 - _x;
		
		_xt -= _ftx / slope;
		
		if(abs(_ftx) < _prec)
			break;
	}
	
	return eval_curve_bezier_cubic_t(_bz, _xt);
}

function eval_curve_bezier_cubic_t(_bz, t) {
	return power(1 - t, 3) * _bz[0]
			 + 3 * power(1 - t, 2) * t * _bz[2] 
			 + 3 * (1 - t) * power(t, 2) * _bz[4]
			 + power(t, 3) * _bz[5];
}

function bezier_range(bz) {
	return [ min(bz[0], bz[2], bz[4], bz[5]), max(bz[0], bz[2], bz[4], bz[5]) ];
}

function bezier_interpol_x(a, b, t, iteration = 10) {
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

function ease_bezier(t, a, b) {
	return 3 * power(1 - t, 2) * t * a + 3 * (1 - t) * power(t, 2) * b + power(t, 3);
}

function ease_cubic_in(rat) {
	return power(rat, 3);
}
function ease_cubic_out(rat) {
	return 1 - power(1 - rat, 3);
}
function ease_cubic_inout(rat) {
	return rat < 0.5 ? 4 * power(rat, 3) : 1 - power(-2 * rat + 2, 3) / 2;
}