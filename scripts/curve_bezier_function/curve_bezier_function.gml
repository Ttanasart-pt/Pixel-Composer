// curve format [-cx0, -cy0, x0, y0, +cx0, +cy0, -cx1, -cy1, x1, y1, +cx1, +cy1]
// segment format [y0, +cx0, +cy0, -cx1, -cy1, y1]
// curve data [x shift, x scale, type, min y, max y, -]

#macro CURVE_PADD 6
#macro CURVE_DEF_00  [0, 1, 0,  0, 1, 0, /**/ 0, 0, 0, 0, 1/3,    0, /**/ -1/3,    0, 1, 0, 0, 0]
#macro CURVE_DEF_01  [0, 1, 0,  0, 1, 0, /**/ 0, 0, 0, 0, 1/3,  1/3, /**/ -1/3, -1/3, 1, 1, 0, 0]
#macro CURVE_DEF_10  [0, 1, 0,  0, 1, 0, /**/ 0, 0, 0, 1, 1/3, -1/3, /**/ -1/3,  1/3, 1, 0, 0, 0]
#macro CURVE_DEF_11  [0, 1, 0,  0, 1, 0, /**/ 0, 0, 0, 1, 1/3,    0, /**/ -1/3,    0, 1, 1, 0, 0]

#macro CURVE_DEFN_00 [0, 1, 0, -1, 1, 0, /**/ 0, 0, 0, 0, 1/3,    0, /**/ -1/3,    0, 1, 0, 0, 0]
#macro CURVE_DEFN_01 [0, 1, 0, -1, 1, 0, /**/ 0, 0, 0, 0, 1/3,  1/3, /**/ -1/3, -1/3, 1, 1, 0, 0]
#macro CURVE_DEFN_10 [0, 1, 0, -1, 1, 0, /**/ 0, 0, 0, 1, 1/3, -1/3, /**/ -1/3,  1/3, 1, 0, 0, 0]
#macro CURVE_DEFN_11 [0, 1, 0, -1, 1, 0, /**/ 0, 0, 0, 1, 1/3,    0, /**/ -1/3,    0, 1, 1, 0, 0]

//////////////////////////////////////////////////////////////////////////////////////////// DRAW ////////////////////////////////////////////////////////////////////////////////////////////

function eval_curve_segment_t_position(_t, bbz) { 
	
	var _t2 = _t * _t;
	var _t3 = _t * _t * _t;
	var _T  =  1 - _t;
	var _T2 = _T * _T;
	var _T3 = _T * _T * _T;
	
	return [ 
		           _T3       * 0 
			 + 3 * _T2 * _t  * bbz[1] 
			 + 3 * _T  * _t2 * bbz[3]
			 +           _t3 * 1, 
			 
			       _T3 *       bbz[0]
			 + 3 * _T2 * _t  * bbz[2] 
			 + 3 * _T  * _t2 * bbz[4]
			 +           _t3 * bbz[5]
		];
}

function draw_curve(x0, y0, _w, _h, _bz, minx = 0, maxx = 1, miny = 0, maxy = 1, _shift = 0, _scale = 1) {
	var _amo  = array_length(_bz);
	var _type = _bz[2];
	
	var segments = (_amo - CURVE_PADD) / 6;
	if(_type == 0) segments--;
	
	var _ox, _oy, _nx, _ny;
	var _rx, _ry;
	
	var rngx = maxx - minx;
	var rngy = maxy - miny;
	
	for( var i = 0; i < segments; i++ ) {
		var ind = CURVE_PADD + i * 6;
		
		var _x0 = _bz[ind + 2];
		var _y0 = _bz[ind + 3];
		
		if(i == 0) {
			_rx = _x0 * _scale + _shift;
			_ry = _y0;
			
			_rx = ( _rx - minx ) / rngx;
			_ry = ( _ry - miny ) / rngy;
			
			_nx = x0 + _w * _rx;
			_ny = y0 + _h * (1 - _ry);
			
			draw_line(x0, _ny, _nx, _ny);
		}
		
		switch(_type) {
			case 0 : 
				var _x1 = _bz[ind + 6 + 2];
				var _y1 = _bz[ind + 6 + 3];
				
				if(i == segments - 1) {
					_rx = _x1 * _scale + _shift;
					_ry = _y1;
					
					_rx = ( _rx - minx ) / rngx;
					_ry = ( _ry - miny ) / rngy;
					
					_nx = x0 + _w * _rx;
					_ny = y0 + _h * (1 - _ry);
					
					draw_line(x0 + _w, _ny, _nx, _ny);
				}
		
				if(_bz[ind + 4] == 0 && _bz[ind + 5] == 0 && _bz[ind + 6 + 0] == 0 && _bz[ind + 6 + 1] == 0) {
					draw_line(x0 + _x0 * _w, y0 + (1 - _y0) * _h, 
					          x0 + _x1 * _w, y0 + (1 - _y1) * _h);
					continue;
				}
				
				var _xr = _x1 - _x0;
				var _yr = _y1 - _y0;
				
				var smp = max(abs(_yr) * _h / 2, ceil(_xr / rngx * 32));
				
				var dx0 = _bz[ind + 4];
				var dy0 = _bz[ind + 5];
				var dx1 = _bz[ind + 6 + 0];
				var dy1 = _bz[ind + 6 + 1];
				
				if(abs(dx0) + abs(dx1) > 1) {
					var _td = abs(dx0) + abs(dx1);
					dx0 /= _td;
					dx1 /= _td;
				}
				
				var ax0 = _x0 + dx0;
				var ay0 = _y0 + dy0;
				
				var bx1 = _x1 + dx1;
				var by1 = _y1 + dy1;
				
				var bbz = [ _y0, ax0, ay0, bx1, by1, _y1 ];
				
				for(var j = 0; j <= smp; j++) {
					var _t  = j / smp;
					var _r  = eval_curve_segment_t_position(_t, bbz);
					
					_rx = _r[0] * _xr + _x0;
					_ry = _r[1];
					
					_rx = _rx * _scale + _shift;
					
					_rx = ( _rx - minx ) / rngx;
					_ry = ( _ry - miny ) / rngy;
					
					_nx = x0 + _w * _rx;
					_ny = y0 + _h * (1 - _ry);
					
					if(j) draw_line(_ox, _oy, _nx, _ny);
					
					_ox = _nx;
					_oy = _ny;
					
					if(_nx > x0 + _w) return;
				}
				break;
				
			case 1 : 
				if(i == segments - 1) {
					_rx = _x0 * _scale + _shift;
					_ry = _y0;
					
					_rx = ( _rx - minx ) / rngx;
					_ry = ( _ry - miny ) / rngy;
					
					_nx = x0 + _w * _rx;
					_ny = y0 + _h * (1 - _ry);
					
					draw_line(x0 + _w, _ny, _nx, _ny);
				}
				
				_rx = _x0 * _scale + _shift;
				_ry = _y0;
				
				_rx = ( _rx - minx ) / rngx;
				_ry = ( _ry - miny ) / rngy;
				
				_nx = x0 + _w * _rx;
				_ny = y0 + _h * (1 - _ry);
				
				if(i) {
					draw_line(_ox, _oy, _nx, _oy);
					draw_line(_nx, _oy, _nx, _ny);
				}
				
				_ox = _nx;
				_oy = _ny;
				break;
		}
	}
}

//////////////////////////////////////////////////////////////////////////////////////////// EVAL ////////////////////////////////////////////////////////////////////////////////////////////

function eval_curve_segment_t(_bz, t) {
	if(_bz[1] == 0 && _bz[2] == 0 && _bz[3] == 0 && _bz[4] == 0)
		return lerp(_bz[0], _bz[5], t);
		
	return         power(1 - t, 3)               * _bz[0]
			 + 3 * power(1 - t, 2) * t           * _bz[2] 
			 + 3 * (1 - t)         * power(t, 2) * _bz[4]
			 +                       power(t, 3) * _bz[5];
}

function eval_curve_x(_bz, _x, _tolr = 0.00001) {
	static _CURVE_DEF_01 = [0, 1, 0, 0, 0, 0, /**/ 0, 0, 0, 0, 1/3,  1/3, /**/ -1/3, -1/3, 1, 1, 0, 0];
	static _CURVE_DEF_10 = [0, 1, 0, 0, 0, 0, /**/ 0, 0, 0, 1, 1/3, -1/3, /**/ -1/3,  1/3, 1, 0, 0, 0];
	static _CURVE_DEF_11 = [0, 1, 0, 0, 0, 0, /**/ 0, 0, 0, 1, 1/3,    0, /**/ -1/3,    0, 1, 1, 0, 0];
	
	var _shift = _bz[0];
	var _scale = _bz[1];
	var _type  = _bz[2];
	var _miny  = _bz[3];
	var _maxy  = _bz[4];
	
	if(_miny == 0 && _maxy == 0)
		_maxy = 1;
	
	_x = _x / _scale - _shift;
	_x = clamp(_x, 0, 1);
	
	if(array_equals_ext(_bz, _CURVE_DEF_11, CURVE_PADD)) return lerp(_miny, _maxy, 1     );
	if(array_equals_ext(_bz, _CURVE_DEF_01, CURVE_PADD)) return lerp(_miny, _maxy,     _x);
	if(array_equals_ext(_bz, _CURVE_DEF_10, CURVE_PADD)) return lerp(_miny, _maxy, 1 - _x);
	
	var segments = (array_length(_bz) - CURVE_PADD) / 6 - 1;
	
	switch(_type) {
		case 0 :
			for( var i = 0; i < segments; i++ ) {
				var ind = CURVE_PADD + i * 6;
				var _x0 = _bz[ind + 2];
				var _y0 = _bz[ind + 3];
				var _x1 = _bz[ind + 6 + 2];
				var _y1 = _bz[ind + 6 + 3];
				
				var dx0 = _bz[ind + 4];
				var dy0 = _bz[ind + 5];
				var dx1 = _bz[ind + 6 + 0];
				var dy1 = _bz[ind + 6 + 1];
				
				if(abs(dx0) + abs(dx1) > 1) {
					var _td = abs(dx0) + abs(dx1);
					dx0 /= _td;
					dx1 /= _td;
				}
				
				var ax0 = _x0 + dx0;
				var ay0 = _y0 + dy0;
				
				var bx1 = _x1 + dx1;
				var by1 = _y1 + dy1;
				
				if(_x < _x0) continue;
				if(_x > _x1) continue;
				
				var _ev = eval_curve_segment_x([_y0, ax0, ay0, bx1, by1, _y1], (_x - _x0) / (_x1 - _x0), _tolr);
				return lerp(_miny, _maxy, _ev);
			}
			break;
			
		case 1 : 
			var _y0 = _bz[CURVE_PADD + 3];
			
			for( var i = 0; i < segments; i++ ) {
				var ind = CURVE_PADD + i * 6;
				var _x0 = _bz[ind + 2];
				
				if(_x <= _x0) return lerp(_miny, _maxy, _y0);
				_y0 = _bz[ind + 3];
			}
			
			return lerp(_miny, _maxy, _y0);
	}
	
	var _ev = array_safe_get_fast(_bz, array_length(_bz) - 3);
	return lerp(_miny, _maxy, _ev);
}

function eval_curve_segment_x(_bz, _x, _tolr = 0.00001) {
	var st = 0;
	var ed = 1;
	
	var _xt = _x;
	var _binRep = 8;
	
	if(_x <= 0) return _bz[0];
	if(_x >= 1) return _bz[5];
	if(_bz[0] == _bz[2] && _bz[0] == _bz[4] && _bz[0] == _bz[5]) return _bz[0];
	// if(_bz[1] == 0 && _bz[2] == 0 && _bz[3] == 0 && _bz[4] == 0)
	// 	return lerp(_bz[0], _bz[5], _x);
		
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
}

//////////////////////////////////////////////////////////////////////////////////////////// MISC ////////////////////////////////////////////////////////////////////////////////////////////

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
		
	static get = function(i) {
		INLINE
		
		var _ind  = clamp(i, 0, 1) * (prec - 1);
		var _indL = floor(_ind);
		var _indH = ceil(_ind);
		var _indF = frac(_ind);
		
		if(_indL == _indH) return map[_ind];
		return lerp(map[_indL], map[_indH], _indF);
	}
}

function draw_curve_bezier(x0, y0, cx0, cy0, cx1, cy1, x1, y1, prec = 32) {
	var ox, oy, nx, ny;
	
	var _st = 1 / prec;
	
	for (var i = 0; i <= prec; i++) {
		var _t  = _st * i;
		var _t1 = 1 - _t;
		
		nx = _t1 * _t1 * _t1 * x0 + 
		     3 * (_t1 * _t1 * _t) * cx0 + 
		     3 * (_t1 * _t  * _t) * cx1 + 
		     _t * _t * _t * x1;
		     
		ny = _t1 * _t1 * _t1 * y0 + 
		     3 * (_t1 * _t1 * _t) * cy0 + 
		     3 * (_t1 * _t  * _t) * cy1 + 
		     _t * _t * _t * y1;
		     
	     if(i) draw_line(ox, oy, nx, ny);
		     
		ox = nx;
		oy = ny;
	}
}