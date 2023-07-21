function Node_Plot_Linear(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Bar / Graph";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Data", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [])
		.setArrayDepth(1)
		.setVisible(true, true);
		
	inputs[| 2] = nodeValue("Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range, [0, 1, 0.01]);
		
	inputs[| 3] = nodeValue("Sample frequency", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 4] = nodeValue("Origin", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, DEF_SURF_H / 2 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 5] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, DEF_SURF_W / 2);
	
	inputs[| 6] = nodeValue("Base Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
		
	inputs[| 7] = nodeValue("Graph Thickness", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 8] = nodeValue("Use Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
		
	inputs[| 9] = nodeValue("Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	inputs[| 10] = nodeValue("Direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 11] = nodeValue("Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Bar chart", "Graph" ]);
	
	inputs[| 12] = nodeValue("Value Offset", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	inputs[| 13] = nodeValue("Color Over Sample", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject(c_white));
	
	inputs[| 14] = nodeValue("Trim mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Range", "Window" ]);
	
	inputs[| 15] = nodeValue("Window Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 8)
	
	inputs[| 16] = nodeValue("Window Offset", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
	
	inputs[| 17] = nodeValue("Spacing", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
	
	inputs[| 18] = nodeValue("Bar Width", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4)
	
	inputs[| 19] = nodeValue("Rounded Bar", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
	
	inputs[| 20] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone)
		.setVisible(true, true);
	
	inputs[| 21] = nodeValue("Flip Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 22] = nodeValue("Loop", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 23] = nodeValue("Smooth", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01 ]);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 0, 
		["Data", 	 true], 1, 12, 21, 14, 2, 3, 15, 16, 
		["Plot",	false], 11, 4, 10, 20, 5, 17, 22, 23, 
		["Render",	false], 6, 13, 7, 18, 19, 8, 9, 
	];
	
	attribute_surface_depth();
	
	static step = function() {
		var _ubg = getSingleValue(8);
		var _typ = getSingleValue(11);
		var _trim_mode = getSingleValue(14);
		
		var _use_path = getSingleValue(20) != noone;
		
		inputs[|  2].setVisible(_trim_mode == 0);
		inputs[| 15].setVisible(_trim_mode == 1);
		inputs[| 16].setVisible(_trim_mode == 1);
		
		inputs[|  9].setVisible(_ubg);
		inputs[|  7].setVisible(_typ == 1);
		inputs[| 18].setVisible(_typ == 0);
		inputs[| 19].setVisible(_typ == 0);
		inputs[| 22].setVisible(_typ == 1);
		inputs[| 23].setVisible(_typ == 1);
		
		inputs[|  4].setVisible(!_use_path);
		inputs[| 10].setVisible(!_use_path);
	}
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _use_path = getSingleValue(20) != noone;
		
		if(!_use_path)
			inputs[| 4].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[ 0];
		var _dat = _data[ 1];
		var _ran = _data[ 2];
		var _sam = _data[ 3]; _sam = max(1, _sam);
		var _ori = _data[ 4];
		var _amp = _data[ 5];
		var _lcl = _data[ 6];
		var _lth = _data[ 7];
		var _ubg = _data[ 8];
		var _bgc = _data[ 9];
		var _ang = _data[10];
		var _typ = _data[11];
		var _off = _data[12];
		var _grd = _data[13];
		
		var _trim_mode = _data[14];
		var _win_size  = _data[15];
		var _win_offs  = _data[16]; _win_offs = max(0, _win_offs);
		
		var _pnt_spac = _data[17];
		
		var _bar_wid = _data[18];
		var _bar_rnd = _data[19];
		
		var _path = _data[20];
		var _flip = _data[21];
		var _loop = _data[22];
		var _smt  = _data[23];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_target(_outSurf);
			if(_ubg) draw_clear(_bgc);
			else	 DRAW_CLEAR
			
			var _len = array_length(_dat);
			var _st  = clamp(_ran[0], 0, 1) * _len;
			var _ed  = clamp(_ran[1], 0, 1) * _len;
			var ox, oy, nx, ny, fx, fy;
			
			if(_typ == 1)
				draw_set_circle_precision(4);
			
			var _dat_amo = array_length(_dat);
			var _smp_data = [];
			var _ind = 0;
			
			if(_trim_mode == 0) {
				for( var i = _st; i < _ed; i += _sam )
					_smp_data[_ind++] = _dat[i];
			} else if(_trim_mode == 1) {
				for( var i = 0; i < _win_size; i++ ) {
					_ind = _win_offs + i * _sam;
					
					if(_ind >= _dat_amo) break;
					if(frac(_ind) != 0 && floor(_ind) + 1 < _dat_amo)
						_smp_data[i] = lerp(_dat[floor(_ind)], _dat[floor(_ind) + 1], frac(_ind));
					else
						_smp_data[i] = _dat[_ind];
					
					if(_flip)
						_smp_data[i] = -_smp_data[i];
				}
			}
			
			var amo = array_length(_smp_data);
			var _px, _py, _ang_nor, _val, _grd_col;
			var _pnt, _ppnt = undefined;
			var _bar_spc = _typ == 1? _pnt_spac : _pnt_spac + _bar_wid;
			
			for( var i = 0; i < amo; i++ ) {
				if(_path == noone) {
					_px = _ori[0] + lengthdir_x(i * _bar_spc, _ang);
					_py = _ori[1] + lengthdir_y(i * _bar_spc, _ang);
				} else {
					_pnt = _path.getPointRatio(i / amo);
					if(_ppnt == undefined)
						_ppnt = _path.getPointRatio(i / amo - 0.001);
					
					_px = _pnt.x;
					_py = _pnt.y;
					_ang = point_direction(_ppnt.x, _ppnt.y, _pnt.x, _pnt.y)
					
					_ppnt = _pnt;
				}
				
				_ang_nor = _ang + 90;
				
				_val = _smp_data[i] + _off;
				
				_grd_col = _grd.eval(i / amo);
				draw_set_color(colorMultiply(_lcl, _grd_col));
				
				nx = _px + lengthdir_x(_amp * _val, _ang_nor);
				ny = _py + lengthdir_y(_amp * _val, _ang_nor);
				
				switch(_typ) {
					case 0 :
						if(_bar_rnd) draw_line_round(_px, _py, nx, ny, _bar_wid);
						else		 draw_line_width(_px, _py, nx, ny, _bar_wid);
						break;
					case 1 :
						if(i > _st) {
							if(_smt > 0) {
								var dist = dot_product(nx - ox, ny - oy, lengthdir_x(1, _ang), lengthdir_y(1, _ang));
								var _b0x = ox + lengthdir_x(dist * _smt, _ang);
								var _b0y = oy + lengthdir_y(dist * _smt, _ang);
								var _b1x = nx + lengthdir_x(dist * _smt, _ang + 180);
								var _b1y = ny + lengthdir_y(dist * _smt, _ang + 180);
								
								//draw_line(ox, oy, _b0x, _b0y);
								//draw_line(_b0x, _b0y, _b1x, _b1y);
								//draw_line(_b1x, _b1y, nx, ny);
								
								var _ox = ox, _oy = oy, _nx, _ny;
								
								for( var j = 1; j <= 8; j++ ) {
									var _t  = 1 - j / 8;
									_nx = ox * power(_t, 3) + 3 * _b0x * power(_t, 2) * (1 - _t) + 3 * _b1x * (_t) * power(1 - _t, 2) + nx * power(1 - _t, 3);
									_ny = oy * power(_t, 3) + 3 * _b0y * power(_t, 2) * (1 - _t) + 3 * _b1y * (_t) * power(1 - _t, 2) + ny * power(1 - _t, 3);
									
									if(_lth > 1) draw_line_round(_ox, _oy, _nx, _ny, _lth);
									else		 draw_line(_ox, _oy, _nx, _ny);
									
									_ox = _nx;
									_oy = _ny;
								}
							} else {
								if(_lth > 1) draw_line_round(ox, oy, nx, ny, _lth);
								else		 draw_line(ox, oy, nx, ny);
							}
						}
						break;
				}
				
				ox = nx;
				oy = ny;
				
				if(i == 0) {
					fx = nx;
					fy = ny;
				}
			}
			
			if(_loop && amo > 1 && _typ == 1)
				draw_line_round(fx, fy, nx, ny, _lth);
			
			draw_set_circle_precision(64);
		surface_reset_target();
		return _outSurf;
	}
}