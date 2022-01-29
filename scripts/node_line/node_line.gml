function Node_create_Line(_x, _y) {
	var node = new Node_Line(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Line(_x, _y) : Node(_x, _y) constructor {
	
	name = "Line";
	
	inputs[| 0] = nodeValue(0, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2, VALUE_TAG.dimension_2d )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Backgroud", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 2] = nodeValue(2, "Segment", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.setDisplay(VALUE_DISPLAY.slider, [1, 32, 1]);
	
	inputs[| 3] = nodeValue(3, "Width", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 2, 2 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue(4, "Wiggle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [0, 16, 0.01]);
	
	inputs[| 5] = nodeValue(5, "Random seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	inputs[| 6] = nodeValue(6, "Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 7] = nodeValue(7, "Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.object, 0);
	
	inputs[| 8] = nodeValue(8, "Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [0, 1])
		.setDisplay(VALUE_DISPLAY.slider_range, [0, 1, 0.01]);
	
	inputs[| 9] = nodeValue(9, "Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY._default, 1 / 64);
	
	inputs[| 10] = nodeValue(10, "Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white)
		.setDisplay(VALUE_DISPLAY.gradient);
	
	input_display_list = [
		["Output",			true],	0, 1, 
		["Line data",		false], 6, 7, 2, 
		["Line settings",	false], 3, 8, 9, 
		["Wiggle",			false], 4, 5, 
		["Render",			false], 10 
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	static update = function() {
		var _dim   = inputs[| 0].getValue();
		var _bg    = inputs[| 1].getValue();
		var _seg   = inputs[| 2].getValue();
		var _wid   = inputs[| 3].getValue();
		var _wig   = inputs[| 4].getValue();
		var _sed   = inputs[| 5].getValue();
		var _ang   = inputs[| 6].getValue() % 360;
		var _pat   = inputs[| 7].getValue();
		var _ratio = inputs[| 8].getValue();
		var _shift = inputs[| 9].getValue();
		
		var _color = inputs[| 10].getValue();
		var _col_data = inputs[| 10].getExtraData();
		
		var _rat   = max(_ratio[0], _ratio[1]) - min(_ratio[0], _ratio[1]);
		var _rats  = min(_ratio[0], _ratio[1]);
		
		var _use_path = _pat != 0 && instanceof(_pat) == "Node_Path";
		if(_ang < 0) _ang = 360 + _ang;
		
		if(_use_path) {
			inputs[| 6].setVisible(false);
		} else {
			inputs[| 6].setVisible(true);	
		}
		
		random_set_seed(_sed);
		
		var _outSurf = outputs[| 0].getValue();
		if(!is_surface(_outSurf)) {
			_outSurf = surface_create(surface_valid(_dim[0]), surface_valid(_dim[1]));
			outputs[| 0].setValue(_outSurf);
		} else
			surface_size_to(_outSurf, surface_valid(_dim[0]), surface_valid(_dim[1]));
		
		surface_set_target(_outSurf);
			if(_bg) draw_clear_alpha(0, 1);
			else	draw_clear_alpha(0, 0);
			
			var _ox, _nx, _oy, _ny, _ow, _nw, _oa, _na;
			
			if(_use_path) {
				var ww = _rat / _seg;
				
				var _total = _rat;
				var _prog_curr = frac(_shift + _rats) - ww, _prog = _prog_curr + 1;
				var _prog_eli = 0;
				
				while(_total > 0) {
					if(_prog_curr >= 1) _prog_curr = 0;
					else _prog_curr = min(_prog_curr + min(_total, ww), 1);
					_prog_eli += min(_total, ww);
					
					var p = _pat.getPointRatio(_prog_curr);
					_nx = p[0];
					_ny = p[1];
					
					if(_total < _rat) {
						_d = point_direction(_ox, _oy, _nx, _ny);
						_nx += lengthdir_x(random(_wig) * choose(-1, 1), _d + 90);
						_ny += lengthdir_y(random(_wig) * choose(-1, 1), _d + 90);
					}
					
					_nw = random_range(_wid[0], _wid[1]);
					
					if(_total <= _prog_curr - _prog) {
						_na = point_direction(_ox, _oy, _nx, _ny) + 90;
					} else {
						var np = _pat.getPointRatio(_prog_curr + ww);
						var _nna = point_direction(_nx, _ny, np[0], np[1]) + 90;
						
						if(_total == _rat)
							_na = _nna;
						else {
							var _da = point_direction(_ox, _oy, _nx, _ny) + 90;
							_na = _da + angle_difference(_nna, _da) / 2;
						}
					}
					
					if(_prog_curr > _prog) {
						draw_set_color(gradient_eval(_color, _prog_eli / _rat, ds_list_get(_col_data, 0)));
						draw_line_width2_angle(_ox, _oy, _nx, _ny, _ow, _nw, _oa, _na);
						_total -= (_prog_curr - _prog);
					}
					
					_prog = _prog_curr;
					_oa = _na;
					_ox = _nx;
					_oy = _ny;
					_ow = _nw;
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
				
				var ww = _rat / _seg;
				var _total = _rat;
				var _prog_curr = frac(_shift + _rats) - ww, _prog = _prog_curr + 1;
				var _prog_eli = 0;
				
				while(_total > 0) {
					if(_prog_curr >= 1) _prog_curr = 0;
					else _prog_curr = min(_prog_curr + min(_total, ww), 1);
					_prog_eli += min(_total, ww);
					
					_nx = x0 + lengthdir_x(_l * _prog_curr, _d);
					_ny = y0 + lengthdir_y(_l * _prog_curr, _d);
					
					_nx += lengthdir_x(random(_wig) * choose(-1, 1), _d + 90);
					_ny += lengthdir_y(random(_wig) * choose(-1, 1), _d + 90);
				
					_nw = random_range(_wid[0], _wid[1]);
					
					if(_prog_curr > _prog) {
						draw_set_color(gradient_eval(_color, _prog_eli / _rat, ds_list_get(_col_data, 0)));
						draw_line_width2_angle(_ox, _oy, _nx, _ny, _ow, _nw, _d + 90, _d + 90);
						_total -= (_prog_curr - _prog);
					}
					
					_prog = _prog_curr;
					_ox = _nx;
					_oy = _ny;
					_ow = _nw;
				}
			}
		surface_reset_target();
	}
	doUpdate();
}