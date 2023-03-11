function Node_Line(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {	
	name = "Line";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2 )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 2] = nodeValue("Segment", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.setDisplay(VALUE_DISPLAY.slider, [1, 32, 1]);
	
	inputs[| 3] = nodeValue("Width", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 2, 2 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue("Wiggle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [0, 16, 0.01]);
	
	inputs[| 5] = nodeValue("Random seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	inputs[| 6] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 7] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone, "Draw line along path.")
		.setVisible(true, true)
		.setArrayDepth(1);
	
	inputs[| 8] = nodeValue("Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [0, 1], "Range of the path to draw.")
		.setDisplay(VALUE_DISPLAY.slider_range, [0, 1, 0.01]);
	
	inputs[| 9] = nodeValue("Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY._default, 1 / 64);
	
	inputs[| 10] = nodeValue("Color over length", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, new gradientObject(c_white) )
		.setDisplay(VALUE_DISPLAY.gradient);
	
	inputs[| 11] = nodeValue("Width over length", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_11);
	
	inputs[| 12] = nodeValue("Span width over path", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Apply the full 'width over length' to the trimmed path.");
		
	inputs[| 13] = nodeValue("Round cap", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 14] = nodeValue("Round segment", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4)
		.setDisplay(VALUE_DISPLAY.slider, [2, 16, 1]);
	
	inputs[| 15] = nodeValue("Span color over path", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Apply the full 'color over length' to the trimmed path.");
	
	inputs[| 16] = nodeValue("Greyscale over width", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 17] = nodeValue("1px mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Render pixel perfect 1px line.");
	
	input_display_list = [
		["Output",			true],	0, 1, 
		["Line data",		false], 6, 7, 2, 
		["Line settings",	false], 17, 3, 11, 12, 8, 9, 13, 14, 
		["Wiggle",			false], 4, 5, 
		["Render",			false], 10, 15, 16, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	lines = [];
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		draw_set_color(COLORS._main_accent);
		for( var i = 0; i < array_length(lines); i++ ) {
			var points = lines[i];
			if(array_length(points) < 2) continue;
				
			for( var j = 1; j < array_length(points); j++ ) {
				var x0 = points[j - 1][0];
				var y0 = points[j - 1][1];
				var x1 = points[j][0];
				var y1 = points[j][1];
				
				x0 = _x + x0 * _s;
				y0 = _y + y0 * _s;
				x1 = _x + x1 * _s;
				y1 = _y + y1 * _s;
				
				draw_line(x0, y0, x1, y1);
			}
		}
	}
	
	static step = function() {
		var px = !inputs[| 17].getValue();
		
		inputs[|  3].setVisible(px);
		inputs[| 11].setVisible(px);
		inputs[| 12].setVisible(px);
		inputs[| 13].setVisible(px);
		inputs[| 14].setVisible(px);
	}
	
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
		var _widc  = _data[11];
		var _widap = _data[12];
		
		var _cap   = _data[13];
		var _capP  = _data[14];
		var _colP  = _data[15];
		var _colW  = _data[16];
		var _1px   = _data[17];
		
		inputs[| 14].setVisible(_cap);
		
		var _rangeMin = min(_ratio[0], _ratio[1]);
		var _rangeMax = max(_ratio[0], _ratio[1]);
		if(_rangeMax == 1) _rangeMax = 0.99999;
		
		var _rtStr = min(_rangeMin, _rangeMax);
		var _rtMax = max(_rangeMin, _rangeMax);
		
		var _use_path = _pat != noone;
		
		if(_ang < 0) _ang = 360 + _ang;
		
		inputs[| 6].setVisible(!_use_path);
		
		random_set_seed(_sed);
		var _sedIndex = 0;
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		surface_set_target(_outSurf);
			if(_bg) draw_clear_alpha(0, 1);
			else	draw_clear_alpha(0, 0);
			
			var _ox, _nx, _nx1, _oy, _ny, _ny1;
			var _ow, _nw, _oa, _na, _oc, _nc;
			lines = [];
			
			if(_use_path) {
				var lineLen = 1;
				var arrPath = is_array(_pat);
				if(arrPath) 
					lineLen = array_length(_pat)
				else if(struct_has(_pat, "getLineCount"))
					lineLen = _pat.getLineCount();
				
				if(_rtMax > 0) 
				for( var i = 0; i < lineLen; i++ ) {
					var _stepLen = min(_rtMax, 1 / _seg);
					if(_stepLen <= 0.00001) continue;
					
					var _total		= _rtMax;
					var _total_prev = _total;
					var _freeze		= 0;
					var _prog_curr	= frac(_shift) - _stepLen;
					var _prog		= _prog_curr + 1;
					var _prog_total	= 0;
					var points		= [];
				
					while(_total > 0) {
						if(_prog_curr >= 1) //cut overflow path
							_prog_curr = frac(_prog_curr);
						else 
							_prog_curr = min(_prog_curr + min(_total, _stepLen), 1); //move forward _stepLen or _total (if less) stop at 1
						_prog_total += min(_total, _stepLen);
						
						var p = arrPath? _pat[i].getPointRatio(_prog_curr) : _pat.getPointRatio(_prog_curr, i);
						_nx   = p[0];
						_ny   = p[1];
						
						if(_total < _rtMax) {
							var _d = point_direction(_ox, _oy, _nx, _ny);
							_nx += lengthdir_x(random1D(_sed + _sedIndex, -_wig, _wig), _d + 90); 
							_sedIndex++;
						
							_ny += lengthdir_y(random1D(_sed + _sedIndex, -_wig, _wig), _d + 90); 
							_sedIndex++;
						}
						
						if(_prog_total > _rtStr) //prevent drawing point before range start.
							array_push(points, [_nx, _ny, _prog_total / _rtMax, _prog_curr]);
						
						if(_prog_curr > _prog)
							_total -= _prog_curr - _prog;
						
						_prog = _prog_curr;
						_ox = _nx;
						_oy = _ny;
					
						if(_total_prev == _total && ++_freeze > 16) break;
						_total_prev = _total;
					}
					
					array_push(lines, points);
				}
			} else {
				var x0, y0, x1, y1;
				var _0 = point_rectangle_overlap(_dim[0], _dim[1], (_ang + 180) % 360);
				var _1 = point_rectangle_overlap(_dim[0], _dim[1], _ang);
				x0 = _0[0]; y0 = _0[1];
				x1 = _1[0]; y1 = _1[1];
			
				var _l = point_distance(x0, y0, x1, y1);
				var _d = point_direction(x0, y0, x1, y1);
				var _od = _d, _nd = _d;
				
				var ww          = _rtMax / _seg;
				var _total		= _rtMax;
				var _prog_curr	= frac(_shift) - ww;
				var _prog		= _prog_curr + 1;
				var _prog_total	= 0;
				var points = [];
				
				while(_total > 0) {
					if(_prog_curr >= 1) _prog_curr = 0;
					else _prog_curr = min(_prog_curr + min(_total, ww), 1);
					_prog_total += min(_total, ww);
					
					_nx = x0 + lengthdir_x(_l * _prog_curr, _d);
					_ny = y0 + lengthdir_y(_l * _prog_curr, _d);
					
					var wgLen = random1D(_sed + _sedIndex, -_wig, _wig); _sedIndex++;
					_nx += lengthdir_x(wgLen, _d + 90); 
					_ny += lengthdir_y(wgLen, _d + 90);
					
					if(_prog_total > _rtStr) //prevent drawing point before range start.
						array_push(points, [_nx, _ny, _prog_total / _rtMax, _prog_curr]);
					
					if(_prog_curr > _prog)
						_total -= (_prog_curr - _prog);
					_prog = _prog_curr;
					_ox = _nx;
					_oy = _ny;
				}
				
				lines = [ points ];
			}
			
			for( var i = 0; i < array_length(lines); i++ ) {
				var points = lines[i];
				if(array_length(points) < 2) continue;
				
				var pxs = [];
				
				for( var j = 0; j < array_length(points); j++ ) {
					var p0   = points[j];
					var _nx  = p0[0];
					var _ny  = p0[1];
					var prog = p0[2];
					var prgc = p0[3];
					
					if(_1px) {
						_nx = _nx - 0.5;	
						_ny = _ny - 0.5;
					}
					
					_nw = random_range(_wid[0], _wid[1]);
					_nw *= eval_curve_x(_widc, _widap? prog : prgc);
					
					_nc = _color.eval(_colP? prog : prgc);
					
					if(_cap) {
						if(j == 1){
							draw_set_color(_oc);
							draw_circle_angle(_ox, _oy, _ow / 2, _d + 180 - 90, _d + 180 + 90, _capP);
						}
						if(j == array_length(points) - 1) {
							draw_set_color(_nc);
							draw_circle_angle(_nx, _ny, _nw / 2, _d - 90, _d + 90, _capP);
						}
					}
					
					if(_1px) {
						if(j) {
							var dst = point_distance(_ox, _oy, _nx, _ny);
							if(dst <= 1 && i < array_length(points) - 1) continue;
							
							//_nc = make_color_hsv(random(255), 255, 255);
							//_oc = _nc;
							//line_bresenham(pxs, _ox, _oy, _nx, _ny, _oc, _nc);
							draw_line_color(_ox, _oy, _nx, _ny, _oc, _nc);
						}
						
						_ox = _nx;
						_oy = _ny;
						_oc = _nc;
					} else {
						if(j) {
							var _nd0 = point_direction(_ox, _oy, _nx, _ny);
							var _nd1 = _nd0;
					
							if(j < array_length(points) - 1) {
								var p2 = points[j + 1];
								var _nnx = p2[0];
								var _nny = p2[1];
						
								_nd1 = point_direction(_nx, _ny, _nnx, _nny);
								_nd = _nd0 + angle_difference(_nd1, _nd0) / 2;
							} else 
								_nd = point_direction(_ox, _oy, _nx, _ny);
						
							draw_line_width2_angle(_ox, _oy, _nx, _ny, _ow, _nw, _od + 90, _nd + 90, _oc, _nc, _colW);
						} else {
							var p1   = points[j + 1];
							_nd = point_direction(_nx, _ny, p1[0], p1[1]);
						}
					
						_ox = _nx;
						_oy = _ny;
						_od = _nd;
						_ow = _nw;
						_oc = _nc;
					}
				}
				
				//if(_1px && array_length(pxs)) {
				//	var ox, oy, nx, ny, px, py;
				//	var lns = [];
					
				//	for( var i = 0; i < array_length(pxs); i++ ) {
				//		nx = pxs[i][0];
				//		ny = pxs[i][1];
						
				//		if(i == 0) {
				//			ox = nx;
				//			oy = ny;
							
				//			px = nx;
				//			py = ny;
				//			continue;
				//		}
						
				//		if((ox != nx && oy != ny) || i == array_length(pxs) - 1) {
				//			array_push(lns, [ ox, oy, nx, ny, pxs[i][2] ]);
							
				//			ox = nx;
				//			oy = ny;
				//		}
						
				//		px = nx;
				//		py = ny;
				//	}
					
				//	ox = pxs[0][0];
				//	oy = pxs[0][1];
				//	_ox = ox;
				//	_oy = oy;
				//	var oc = pxs[0][2], nc;
					
				//	//print("=====")
				//	//for( var i = 1; i < array_length(lns) - 1; i++ ) {
				//	//	var l0 = lns[i - 1];
				//	//	var l1 = lns[i + 0];
				//	//	var l2 = lns[i + 1];
						
				//	//	var d0 = l0[1] * l0[1] + l0[0] * l0[0];
				//	//	var d1 = l1[1] * l1[1] + l1[0] * l1[0];
				//	//	var d2 = l2[1] * l2[1] + l2[0] * l2[0];
						
				//	//	if(sign(d1 - d0) != sign(d2 - d1) && d0 != d1 && d1 != d2 && d0 != d2) {
				//	//		print(string(d0) + ", " + string(d1) + ", " + string(d2) + ", ");
				//	//		//var t1 = l1[0];
				//	//		//var t2 = l1[1];
							
				//	//		//lns[i + 0][0] = l2[0];
				//	//		//lns[i + 0][1] = l2[1];
				//	//		//lns[i + 1][0] = t1;
				//	//		//lns[i + 1][1] = t2;
							
				//	//		lns[i + 0][2] = c_red;
				//	//		lns[i + 1][2] = c_lime;
				//	//	}
				//	//}
					
				//	for( var i = 0; i < array_length(lns); i++ ) {
				//		var ll = lns[i];
				//		//print(string(ll[0]) + ", " + string(ll[1]) + ": " + string(ll[1] / ll[0]));
						
				//		nc = ll[4];
						
				//		nc = make_color_hsv(random(255), 255, 255);
				//		oc = nc;
				//		draw_line_color(ll[0], ll[1], ll[2], ll[3], oc, nc);
						
				//		ox = nx;
				//		oy = ny;
				//		oc = nc;
				//	}
					
				//	if(point_distance(nx, ny, _ox, _oy) <= 1)
				//		draw_line_color(nx, ny, _ox, _oy, nc, nc);
				//}
			}
		surface_reset_target();
		
		return _outSurf;
	}
}