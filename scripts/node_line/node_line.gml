function Node_Line(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {	
	name = "Line";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2 )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Backgroud", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 2] = nodeValue("Segment", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.setDisplay(VALUE_DISPLAY.slider, [1, 32, 1]);
	
	inputs[| 3] = nodeValue("Width", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 2, 2 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue("Wiggle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [0, 16, 0.01]);
	
	inputs[| 5] = nodeValue("Random seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	inputs[| 6] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 7] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, 0, "Draw line along path.")
		.setVisible(true, true);
	
	inputs[| 8] = nodeValue("Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [0, 1], "Range of the path to draw.")
		.setDisplay(VALUE_DISPLAY.slider_range, [0, 1, 0.01]);
	
	inputs[| 9] = nodeValue("Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY._default, 1 / 64);
	
	inputs[| 10] = nodeValue("Color over length", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, [ new gradientKey(0, c_white) ] )
		.setDisplay(VALUE_DISPLAY.gradient);
	
	inputs[| 11] = nodeValue("Width over length", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_11);
	
	inputs[| 12] = nodeValue("Span width over path", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Apply the full 'width over length' to the trimmed path.");
		
	inputs[| 13] = nodeValue("Round cap", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 14] = nodeValue("Round segment", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4)
		.setDisplay(VALUE_DISPLAY.slider, [2, 16, 1]);
	
	inputs[| 15] = nodeValue("Span color over path", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Apply the full 'color over length' to the trimmed path.");
	
	inputs[| 16] = nodeValue("Greyscale over width", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	input_display_list = [
		["Output",			true],	0, 1, 
		["Line data",		false], 6, 7, 2, 
		["Line settings",	false], 3, 11, 12, 8, 9, 13, 14, 
		["Wiggle",			false], 4, 5, 
		["Render",			false], 10, 15, 16, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _dim   = _data[0];
		var _bg    = _data[1];
		var _seg   = _data[2];
		var _wid   = _data[3];
		var _wig   = _data[4];
		var _sed   = _data[5];
		var _ang   = _data[6] % 360;
		var _pat   = _data[7];
		var _ratio = _data[8];
		var _shift = _data[9];
		
		var _color = _data[10];
		var _col_data = inputs[| 10].getExtraData();
		var _widc  = _data[11];
		var _widap = _data[12];
		
		var _cap   = _data[13];
		var _capP  = _data[14];
		var _colP  = _data[15];
		var _colW  = _data[16];
		
		inputs[| 14].setVisible(_cap);
		
		var _rangeMin = min(_ratio[0], _ratio[1]);
		var _rangeMax = max(_ratio[0], _ratio[1]);
		if(_rangeMax == 1) _rangeMax = 0.99999;
		
		var _rtStr = _rangeMin;
		var _rtLen = _rangeMax - _rangeMin;
		
		var _use_path = _pat != noone && struct_has(_pat, "getPointRatio");
		if(_ang < 0) _ang = 360 + _ang;
		
		inputs[| 6].setVisible(!_use_path);
		
		random_set_seed(_sed);
		var _sedIndex = 0;
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		surface_set_target(_outSurf);
			if(_bg) draw_clear_alpha(0, 1);
			else	draw_clear_alpha(0, 0);
			
			var _ox, _nx, _oy, _ny, _ow, _nw, _oa, _na, _oc, _nc;
			
			if(_use_path) {
				var ww = _rtLen / _seg;
				
				var _total		= _rtLen;
				var _total_prev = _total;
				var _freeze		= 0;
				var _prog_curr	= frac(_shift + _rtStr) - ww;
				var _prog		= _prog_curr + 1;
				var _prog_eli	= 0;
				var step = 0;
				
				while(_total > 0) {
					if(_rtLen == 0) break;
					if(ww <= 0.001) break;
					
					if(_prog_curr >= 1) 
						_prog_curr = frac(_prog_curr);
					else 
						_prog_curr = min(_prog_curr + min(_total, ww), 1);
					_prog_eli = _prog_eli + min(_total, ww);
					
					var p = _pat.getPointRatio(_prog_curr);
					_nx = p[0];
					_ny = p[1];
					
					if(_total < _rtLen) {
						var _d = point_direction(_ox, _oy, _nx, _ny);
						_nx += lengthdir_x(random1D(_sed + _sedIndex, -_wig, _wig), _d + 90); 
						_sedIndex++;
						
						_ny += lengthdir_y(random1D(_sed + _sedIndex, -_wig, _wig), _d + 90); 
						_sedIndex++;
					}
					
					_nw = random_range(_wid[0], _wid[1]);
					_nw *= eval_curve_x(_widc, _widap? _prog_eli / _rtLen : _prog_curr);
					
					if(_total <= _prog_curr - _prog) {
						_na = point_direction(_ox, _oy, _nx, _ny) + 90;
					} else {
						var n0 = _pat.getPointRatio(_prog_curr - 0.001);
						var n1 = _pat.getPointRatio(_prog_curr + 0.001);
						_na = point_direction(n0[0], n0[1], n1[0], n1[1]) + 90;
					}
					
					_nc = gradient_eval(_color, _colP? _prog_eli / _rtLen : _prog_curr, ds_list_get(_col_data, 0));
					
					if(_prog_curr > _prog) {
						if(_cap) {
							if(_total == _rtLen) {
								draw_set_color(_oc);
								draw_circle_angle(_ox, _oy, _ow / 2, _oa, _oa + 180, _capP);
							}
							if(_total - (_prog_curr - _prog) <= 0) {
								draw_set_color(_nc);
								draw_circle_angle(_nx, _ny, _nw / 2, _na - 180, _na, _capP);
							}
						}
						
						draw_line_width2_angle(_ox, _oy, _nx, _ny, _ow, _nw, _oa, _na, _oc, _nc, _colW);
						_total -= _prog_curr - _prog;
					}
					
					_prog = _prog_curr;
					_oa = _na;
					_ox = _nx;
					_oy = _ny;
					_ow = _nw;
					_oc = _nc;
					
					if(_total_prev == _total && ++_freeze > 16) break;
					_total_prev = _total;
				}
			} else {
				var x0, y0, x1, y1;
				var _0 = point_rectangle_overlap(_dim[0], _dim[1], (_ang + 180) % 360);
				var _1 = point_rectangle_overlap(_dim[0], _dim[1], _ang);
				x0 = _0[0];
				y0 = _0[1];
				x1 = _1[0];
				y1 = _1[1];
			
				var _l = point_distance(x0, y0, x1, y1);
				var _d = point_direction(x0, y0, x1, y1);
				
				var ww = _rtLen / _seg;
				var _total		= _rtLen;
				var _prog_curr	= frac(_shift + _rtStr) - ww;
				var _prog		= _prog_curr + 1;
				var _prog_eli	= 0;
				
				while(_total > 0) {
					if(_prog_curr >= 1) _prog_curr = 0;
					else _prog_curr = min(_prog_curr + min(_total, ww), 1);
					_prog_eli += min(_total, ww);
					
					_nx = x0 + lengthdir_x(_l * _prog_curr, _d);
					_ny = y0 + lengthdir_y(_l * _prog_curr, _d);
					
					_nx += lengthdir_x(random1D(_sed + _sedIndex, -_wig, _wig), _d + 90);
					_sedIndex++;
					
					_ny += lengthdir_y(random1D(_sed + _sedIndex, -_wig, _wig), _d + 90);
					_sedIndex++;
				
					_nw = random_range(_wid[0], _wid[1]);
					_nw *= eval_curve_x(_widc, _widap? _prog_eli / _rtLen : _prog_curr);
					
					_nc = gradient_eval(_color, _colP? _prog_eli / _rtLen : _prog_curr, ds_list_get(_col_data, 0));
					
					if(_prog_curr > _prog) {
						if(_cap) {
							if(_total == _rtLen){
								draw_set_color(_oc);
								draw_circle_angle(_ox, _oy, _ow / 2, _d + 180 - 90, _d + 180 + 90, _capP);
							}
							if(_total - (_prog_curr - _prog) <= 0){
								draw_set_color(_nc);
								draw_circle_angle(_nx, _ny, _nw / 2, _d - 90, _d + 90, _capP);
							}
						}
						
						draw_line_width2_angle(_ox, _oy, _nx, _ny, _ow, _nw, _d + 90, _d + 90, _oc, _nc, _colW);
						_total -= (_prog_curr - _prog);
					}
					
					_prog = _prog_curr;
					_ox = _nx;
					_oy = _ny;
					_ow = _nw;
					_oc = _nc;
				}
			}
		surface_reset_target();
		
		return _outSurf;
	}
}