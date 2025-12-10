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

	////- DRAW

function draw_curve(x0, y0, _w, _h, _bz, minx = 0, maxx = 1, miny = 0, maxy = 1, _shift = 0, _scale = 1) {
	if(!is_array(_bz)) return;
	
	var _amo  = array_length(_bz);
	if(_amo < CURVE_PADD) return;
	
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
					var _rx0 = ( _x0 - minx ) / rngx;
					var _ry0 = ( _y0 - miny ) / rngy;
					var _rx1 = ( _x1 - minx ) / rngx;
					var _ry1 = ( _y1 - miny ) / rngy;
					
					var px0 = x0 + _rx0 * _w;
					var py0 = y0 + (1 - _ry0) * _h;
					var px1 = x0 + _rx1 * _w;
					var py1 = y0 + (1 - _ry1) * _h;
					
					draw_line(px0, py0, px1, py1);
					continue;
				}
				
				var _xr = _x1 - _x0;
				var _yr = _y1 - _y0;
				
				var smp = max(abs(_yr) * _h / 2, ceil(_xr / rngx * 32));
				
				var dx0 = _bz[ind + 4];
				var dy0 = _bz[ind + 5];
				var dx1 = _bz[ind + 6 + 0];
				var dy1 = _bz[ind + 6 + 1];
				
				if(abs(dx0) + abs(dx1) > abs(_x0 - _x1) * 2) {
					var _rdx = (abs(_x0 - _x1) * 2) / (abs(dx0) + abs(dx1));
					dx0 *= _rdx;
					dx1 *= _rdx;
				}
				
				var ax0 = _x0 + dx0;
				var ay0 = _y0 + dy0;
				
				var bx1 = _x1 + dx1;
				var by1 = _y1 + dy1;
				
				for(var j = 0; j <= smp; j++) {
					var _t  = j / smp;
					
					var _t2 = _t * _t;
					var _t3 = _t * _t * _t;
					var _T  =  1 - _t;
					var _T2 = _T * _T;
					var _T3 = _T * _T * _T;
					
					var _r0 =       _T3 *       _x0
					          + 3 * _T2 * _t  * ax0
					          + 3 * _T  * _t2 * bx1
					          +           _t3 * _x1;
					
					_rx = _r0;
					_rx = _rx * _scale + _shift;
					
					var _r1 =       _T3 *       _y0 
					          + 3 * _T2 * _t  * ay0
					          + 3 * _T  * _t2 * by1
					          +           _t3 * _y1;
					_ry = _r1;
					
					////////////////////////////////////////////////
					
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

	////- EVAL

function eval_curve_segment_t(_y0, ay0, by1, _y1, t) {
	var i = 1-t;
	
	return  _y0 *     i*i*i + 
		    ay0 * 3 * i*i*t +
		    by1 * 3 * i*t*t +
		    _y1 *     t*t*t ;
}

function eval_curve_segment_x(_y0, ax0, ay0, bx1, by1, _y1, _x, _tolr = 0.0001) {
	static _binRep = 8;
	
	if(_x <= 0) return _y0;
	if(_x >= 1) return _y1;
	if(_y0 == ay0 && _y0 == by1 && _y0 == _y1) return _y0;
	
	var st =  0;
	var ed =  1;
	var t  = .5;
	
	var t = _x;
	repeat(_binRep) {
		var _t = 1-t;
		var ft =  3 * _t * _t * t * ax0 
			    + 3 * _t *  t * t * bx1
			    +      t *  t * t;
		
		if(abs(ft - _x) < _tolr) 
			return eval_curve_segment_t(_y0, ay0, by1, _y1, t);
		
		var dfdt =  3 * _t * _t *  ax0
				  + 6 * _t *  t * (bx1 - ax0)
				  + 3 *  t *  t * (1 - bx1);
		
		t = t - (ft - _x) / dfdt;
	}
	
	return eval_curve_segment_t(_y0, ay0, by1, _y1, t);
}

function eval_curve_x(_bz, _x, _tolr = 0.0001) {
	static _CURVE_DEF_01 = [0, 1, 0, 0, 0, 0, /**/ 0, 0, 0, 0, 1/3,  1/3, /**/ -1/3, -1/3, 1, 1, 0, 0];
	static _CURVE_DEF_10 = [0, 1, 0, 0, 0, 0, /**/ 0, 0, 0, 1, 1/3, -1/3, /**/ -1/3,  1/3, 1, 0, 0, 0];
	static _CURVE_DEF_11 = [0, 1, 0, 0, 0, 0, /**/ 0, 0, 0, 1, 1/3,    0, /**/ -1/3,    0, 1, 1, 0, 0];
	
	if(!is_array(_bz) || array_length(_bz) < CURVE_PADD) return 0;
	
	var _shift = _bz[0];
	var _scale = _bz[1];
	var _type  = _bz[2];
	var _miny  = _bz[3];
	var _maxy  = _bz[4];
	
	if(_miny == 0 && _maxy == 0)
		_maxy = 1;
	
	_x = _x / _scale - _shift;
	_x = clamp(_x, 0, 1);
	
	if(array_equals_ext_fast(_bz, _CURVE_DEF_11, CURVE_PADD)) return lerp(_miny, _maxy, 1     );
	if(array_equals_ext_fast(_bz, _CURVE_DEF_01, CURVE_PADD)) return lerp(_miny, _maxy,     _x);
	if(array_equals_ext_fast(_bz, _CURVE_DEF_10, CURVE_PADD)) return lerp(_miny, _maxy, 1 - _x);
	
	var segments = (array_length(_bz) - CURVE_PADD) / 6 - 1;
	
	switch(_type) {
		case 0 :
			for( var i = 0; i < segments; i++ ) {
				var ind = CURVE_PADD + i * 6;
				var _x0 = _bz[ind + 2];
				var _y0 = _bz[ind + 3];
				var _x1 = _bz[ind + 6 + 2];
				var _y1 = _bz[ind + 6 + 3];
				
				if(_x < _x0) continue;
				if(_x > _x1) continue;
				
				var dx0 = _bz[ind + 4];
				var dy0 = _bz[ind + 5];
				var dx1 = _bz[ind + 6 + 0];
				var dy1 = _bz[ind + 6 + 1];
				
				if(abs(dx0) + abs(dx1) > abs(_x0 - _x1) * 2) {
					var _rdx = (abs(_x0 - _x1) * 2) / (abs(dx0) + abs(dx1));
					dx0 *= _rdx;
					dx1 *= _rdx;
				}
				
				var _rx = _x1 - _x0;
				var  t  = (_x - _x0) / _rx;
				
				if(dx0 == 0. && dy0 == 0. && dx1 == 0. && dy1 == 0.)
                    return lerp(_y0, _y1, t);
				
				var ax0 = 0 + dx0 / _rx;
				var ay0 = _y0 + dy0;
				
				var bx1 = 1 + dx1 / _rx;
				var by1 = _y1 + dy1;
				
				return eval_curve_segment_x(_y0, ax0, ay0, bx1, by1, _y1, t, _tolr);
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

	////- CMF

function eval_curve_cmf(_c, _res = 128) {
	var _st  = 1 / (_res - 1);
	var _cv  = 0;
	var _cmf = array_create(_res);
	
	for( var i = 0; i < _res; i++ ) {
		var _i = i * _st;
		var _v = eval_curve_x(_c, _i);
		
		_cmf[i] = _cv;
		_cv    += _v;
	}
	
	for( var i = 0; i < _res; i++ ) // normalize
		_cmf[i] /= _cv;
		
	return _cmf;
}

	////- MISC

function bezier_range(bz) { return [ min(bz[0], bz[2], bz[4], bz[5]), max(bz[0], bz[2], bz[4], bz[5]) ]; }

function ease_cubic_in(rat)    { return power(rat, 3); }
function ease_cubic_out(rat)   { return 1 - power(1 - rat, 3); }
function ease_cubic_inout(rat) { return rat < 0.5 ? 4 * power(rat, 3) : 1 - power(-2 * rat + 2, 3) / 2; }

function curveMap(_bz = undefined, _prec = 32, _tolr = 0.00001) constructor {
	bz   = undefined;
	prec = _prec;
	size = 1 / _prec;
	tolr = _tolr;
	map  = array_create(prec);
	
	static get = function(i) {
		INLINE
		
		var _ind  = clamp(i, 0, 1) * (prec - 1);
		var _indL = floor(_ind);
		var _indH = ceil(_ind);
		var _indF = frac(_ind);
		
		if(_indL == _indH) return map[_ind];
		return lerp(map[_indL], map[_indH], _indF);
	}
	
	static set = function(_bz) {
		if(_bz == undefined)      return;
		if(array_equals(bz, _bz)) return;
		
		bz = array_clone(_bz, 1);
		for( var i = 0; i < prec; i++ ) 
			map[i] = eval_curve_x(bz, i * size, tolr);
		
	}
	
	set(_bz);
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

	////- MISC

function curve_flip_h(_bz) {
	var _amo   = array_length(_bz);
	var points = (_amo - CURVE_PADD) / 6;
	var _idata = array_create(_amo);
	
	for( var i = 0; i < CURVE_PADD; i++ ) 
		_idata[i] = _bz[i];
	
	for( var i = 0; i < points; i++ ) {
		var ivd = CURVE_PADD + (points - i - 1) * 6;
		var ind = CURVE_PADD + i * 6;
		
		var _x0 = _bz[ivd + 2];
		var _y0 = _bz[ivd + 3];
		
		var bx0 = _bz[ivd + 0];
		var by0 = _bz[ivd + 1];
		var ax0 = _bz[ivd + 4];
		var ay0 = _bz[ivd + 5];
		
		_idata[ind + 0] =  -ax0;
		_idata[ind + 1] =   ay0;
		_idata[ind + 2] = 1-_x0;
		_idata[ind + 3] =   _y0;
		_idata[ind + 4] =  -bx0;
		_idata[ind + 5] =   by0;
	}
	
	return _idata;
}

function curve_flip_v(_bz) {
	var _amo   = array_length(_bz);
	var points = (_amo - CURVE_PADD) / 6;
	var _idata = array_create(_amo);
	
	for( var i = 0; i < CURVE_PADD; i++ ) 
		_idata[i] = _bz[i];
	
	for( var i = 0; i < points; i++ ) {
		var ivd = CURVE_PADD + (points - i - 1) * 6;
		var ind = CURVE_PADD + i * 6;
		
		var _x0 = _bz[ind + 2];
		var _y0 = _bz[ind + 3];
		
		var bx0 = _bz[ind + 0];
		var by0 = _bz[ind + 1];
		var ax0 = _bz[ind + 4];
		var ay0 = _bz[ind + 5];
		
		_idata[ind + 0] =   bx0;
		_idata[ind + 1] =  -by0;
		_idata[ind + 2] =   _x0;
		_idata[ind + 3] = 1-_y0;
		_idata[ind + 4] =   ax0;
		_idata[ind + 5] =  -ay0;
	}
		
	return _idata;
}