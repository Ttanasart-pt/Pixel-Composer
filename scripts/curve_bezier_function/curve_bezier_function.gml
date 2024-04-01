//curve format [-cx0, -cy0, x0, y0, +cx0, +cy0, -cx1, -cy1, x1, y1, +cx1, +cy1]
//segment format [y0, +cx0, +cy0, -cx1, -cy1, y1]

#macro CURVE_DEF_00 [0, 0, 0, 0, 1/3,    0, /**/ -1/3,    0, 1, 0, 0, 0]
#macro CURVE_DEF_01 [0, 0, 0, 0, 1/3,  1/3, /**/ -1/3, -1/3, 1, 1, 0, 0]
#macro CURVE_DEF_10 [0, 0, 0, 1, 1/3, -1/3, /**/ -1/3,  1/3, 1, 0, 0, 0]
#macro CURVE_DEF_11 [0, 0, 0, 1, 1/3,    0, /**/ -1/3,    0, 1, 1, 0, 0]

function draw_curve(x0, y0, _w, _h, _bz, miny = 0, maxy = 1) { #region
	var segments = array_length(_bz) / 6 - 1;
	
	for( var i = 0; i < segments; i++ ) {
		var ind = i * 6;
		var _x0 = _bz[ind + 2];
		var _y0 = _bz[ind + 3];
	  //var bx0 = _x0 + _bz[ind + 0];
	  //var by0 = _y0 + _bz[ind + 1];
		var ax0 = _x0 + _bz[ind + 4];
		var ay0 = _y0 + _bz[ind + 5];
		
		var _x1 = _bz[ind + 6 + 2];
		var _y1 = _bz[ind + 6 + 3];
		var bx1 = _x1 + _bz[ind + 6 + 0];
		var by1 = _y1 + _bz[ind + 6 + 1];
	  //var ax1 = _x1 + _bz[ind + 6 + 4];
	  //var ay1 = _y1 + _bz[ind + 6 + 5];
		
		var dx0 = x0 + _w * _x0;
		var dx1 = x0 + _w * _x1;
		var dw  = dx1 - dx0;
		var smp = ceil((_x1 - _x0) * 32);
		
		draw_curve_segment(dx0, y0, dw, _h, [_y0, ax0, ay0, bx1, by1, _y1], smp, miny, maxy);
	}
} #endregion

function draw_curve_segment(x0, y0, _w, _h, _bz, SAMPLE = 32, miny = 0, maxy = 1) { #region
	var _ox, _oy;
	
	for(var i = 0; i <= SAMPLE; i++) {
		var t = i / SAMPLE;
		var _r  = eval_curve_segment_t_position(t, _bz);
		var _rx = _r[0], _ry = _r[1];
		_ry = (_ry - miny) / (maxy - miny);
		
		var _nx = _rx * _w + x0;
		var _ny = (_h? _ry : 1 - _ry) * abs(_h) + y0;
		
		if(i) 
			draw_line(_ox, _oy, _nx, _ny);
		
		_ox = _nx;
		_oy = _ny;
	}
} #endregion

function eval_curve_segment_t_position(t, _bz) { #region
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
} #endregion

function eval_curve_segment_t(_bz, t) { #region
	return power(1 - t, 3) * _bz[0]
			 + 3 * power(1 - t, 2) * t * _bz[2] 
			 + 3 * (1 - t) * power(t, 2) * _bz[4]
			 + power(t, 3) * _bz[5];
} #endregion

function eval_curve_x(_bz, _x, _tolr = 0.00001) { #region
	static _CURVE_DEF_01 = [0, 0, 0, 0, 1/3,  1/3, /**/ -1/3, -1/3, 1, 1, 0, 0];
	static _CURVE_DEF_10 = [0, 0, 0, 1, 1/3, -1/3, /**/ -1/3,  1/3, 1, 0, 0, 0];
	static _CURVE_DEF_11 = [0, 0, 0, 1, 1/3,    0, /**/ -1/3,    0, 1, 1, 0, 0];
	
	if(array_equals(_bz, _CURVE_DEF_11)) return 1;
	if(array_equals(_bz, _CURVE_DEF_01)) return _x;
	if(array_equals(_bz, _CURVE_DEF_10)) return 1 - _x;
	
	var segments = array_length(_bz) / 6 - 1;
	_x = clamp(_x, 0, 1);
	
	for( var i = 0; i < segments; i++ ) {
		var ind = i * 6;
		var _x0 = _bz[ind + 2];
		var _y0 = _bz[ind + 3];
	  //var bx0 = _x0 + _bz[ind + 0];
	  //var by0 = _y0 + _bz[ind + 1];
		var ax0 = _x0 + _bz[ind + 4];
		var ay0 = _y0 + _bz[ind + 5];
		
		var _x1 = _bz[ind + 6 + 2];
		var _y1 = _bz[ind + 6 + 3];
		var bx1 = _x1 + _bz[ind + 6 + 0];
		var by1 = _y1 + _bz[ind + 6 + 1];
	  //var ax1 = _x1 + _bz[ind + 6 + 4];
	  //var ay1 = _y1 + _bz[ind + 6 + 5];
		
		if(_x < _x0) continue;
		if(_x > _x1) continue;
		
		return eval_curve_segment_x([_y0, ax0, ay0, bx1, by1, _y1], (_x - _x0) / (_x1 - _x0), _tolr);
	}
	
	return array_safe_get_fast(_bz, array_length(_bz) - 3);
} #endregion

function eval_curve_segment_x(_bz, _x, _tolr = 0.00001) { #region
	var st = 0;
	var ed = 1;
	
	var _xt = _x;
	var _binRep = 8;
	
	if(_x <= 0) return _bz[0];
	if(_x >= 1) return _bz[5];
	if(_bz[0] == _bz[2] && _bz[0] == _bz[4] && _bz[0] == _bz[5]) return _bz[0];
	
	repeat(_binRep) {
		var _1xt = 1 - _xt;
		
		var _ftx =  3 * _1xt * _1xt * _xt * _bz[1] 
			      + 3 * _1xt *  _xt * _xt * _bz[3]
			      +      _xt *  _xt * _xt;
		
		if(abs(_ftx - _x) < _tolr)
			return eval_curve_segment_t(_bz, _xt);
		
		if(_xt < _x) st = _xt;
		else         ed = _xt;
		
		_xt = (st + ed) / 2;
	}
	
	var _newRep = 8;
	
	repeat(_newRep) {
		var _bz1 = _bz[1];
		var _bz3 = _bz[3];
		
		var slope =   (  9 * _bz1 - 9 * _bz3 + 3) * _xt * _xt
					+ (-12 * _bz1 + 6 * _bz3) * _xt
					+    3 * _bz1;
		
		var _1xt = 1 - _xt;
		
		var _ftx = 3 * _1xt * _1xt * _xt * _bz1 
				 + 3 * _1xt *  _xt * _xt * _bz3
				 +      _xt *  _xt * _xt
				 - _x;
		
		_xt -= _ftx / slope;
		
		if(abs(_ftx) < _tolr)
			break;
	}
	
	_xt = clamp(_xt, 0, 1);
	return eval_curve_segment_t(_bz, _xt);
} #endregion

function bezier_range(bz) { return [ min(bz[0], bz[2], bz[4], bz[5]), max(bz[0], bz[2], bz[4], bz[5]) ]; }

function ease_cubic_in(rat)    { return power(rat, 3); }
function ease_cubic_out(rat)   { return 1 - power(1 - rat, 3); }
function ease_cubic_inout(rat) { return rat < 0.5 ? 4 * power(rat, 3) : 1 - power(-2 * rat + 2, 3) / 2; }

function curveMap(_bz, _prec = 32, _tolr = 0.00001) constructor {
	bz   = _bz;
	prec = _prec;
	size = 1 / _prec;
	tolr = _tolr;
	 
	map = array_create(_prec);
	for( var i = 0; i < _prec; i++ ) 
		map[i] = eval_curve_x(bz, i * size, tolr);
		
	static get = function(i) { #region
		INLINE
		
		var _ind  = clamp(i, 0, 1) * (prec - 1);
		var _indL = floor(_ind);
		var _indH = ceil(_ind);
		var _indF = frac(_ind);
		
		if(_indL == _indH) return map[_ind];
		return lerp(map[_indL], map[_indH], _indF);
	} #endregion
}