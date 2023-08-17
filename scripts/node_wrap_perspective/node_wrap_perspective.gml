function Node_Warp_Perspective(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Perspective Warp";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 1;
		
	inputs[| 2] = nodeValue("Top left", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 3] = nodeValue("Top right", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ DEF_SURF_W, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 4] = nodeValue("Bottom left", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, DEF_SURF_H ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 5] = nodeValue("Bottom right", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
		
	inputs[| 6] = nodeValue("Top left", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 7] = nodeValue("Top right", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ DEF_SURF_W, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 8] = nodeValue("Bottom left", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, DEF_SURF_H ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 9] = nodeValue("Bottom right", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 1,
		["Output", 	 false], 0,
		["Origin",	 false], 2, 3, 4, 5, 
		["Warp",	 false], 6, 7, 8, 9,
	]
	
	attribute_surface_depth();
	attribute_interpolation();

	drag_side = -1;
	drag_mx = 0;
	drag_my = 0;
	drag_s = [[0, 0], [0, 0]];
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(array_length(current_data) < ds_list_size(inputs)) return;
		
		var _surf = outputs[| 0].getValue();
		if(is_array(_surf)) {
			if(array_length(_surf) == 0) return;
			_surf = _surf[preview_index];
		}
		
		if(drag_side > -1) {
			dx = (_mx - drag_mx) / _s;
			dy = (_my - drag_my) / _s;
				
			if(mouse_release(mb_left)) {
				drag_side = -1;	
				UNDO_HOLDING = false;
			}
		}
		
		var tool = 1;
		
		var tl = current_data[tool * 4 + 2];
		var tr = current_data[tool * 4 + 3];
		var bl = current_data[tool * 4 + 4];
		var br = current_data[tool * 4 + 5];
		
		tl[0] = _x + tl[0] * _s;
		tr[0] = _x + tr[0] * _s;
		bl[0] = _x + bl[0] * _s;
		br[0] = _x + br[0] * _s;
		
		tl[1] = _y + tl[1] * _s;
		tr[1] = _y + tr[1] * _s;
		bl[1] = _y + bl[1] * _s;
		br[1] = _y + br[1] * _s;
		
		draw_set_color(COLORS._main_accent);
		draw_line(tl[0], tl[1], tr[0], tr[1]);
		draw_line(tl[0], tl[1], bl[0], bl[1]);
		draw_line(br[0], br[1], tr[0], tr[1]);
		draw_line(br[0], br[1], bl[0], bl[1]);
		
		if(inputs[| tool * 4 + 2].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny)) active = false;
		if(inputs[| tool * 4 + 3].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny)) active = false;
		if(inputs[| tool * 4 + 4].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny)) active = false;
		if(inputs[| tool * 4 + 5].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny)) active = false;
		
		var dx = 0;
		var dy = 0;
			
		draw_set_color(COLORS.node_overlay_gizmo_inactive);
		if(drag_side == tool * 4 + 2) {
			draw_line_width(tl[0], tl[1], tr[0], tr[1], 3);
			
			var _tlx = value_snap(drag_s[0][0] + dx, _snx);
			var _tly = value_snap(drag_s[0][1] + dy, _sny);
			
			var _trx = value_snap(drag_s[1][0] + dx, _snx);
			var _try = value_snap(drag_s[1][1] + dy, _sny);
			
			   inputs[| tool * 4 + 2].setValue([ _tlx, _tly ])
			if(inputs[| tool * 4 + 3].setValue([ _trx, _try ])) UNDO_HOLDING = true;
		} else if(drag_side == tool * 4 + 3) {
			draw_line_width(tl[0], tl[1], bl[0], bl[1], 3);
			
			var _tlx = value_snap(drag_s[0][0] + dx, _snx);
			var _tly = value_snap(drag_s[0][1] + dy, _sny);
								  
			var _blx = value_snap(drag_s[1][0] + dx, _snx);
			var _bly = value_snap(drag_s[1][1] + dy, _sny);
			
			   inputs[| tool * 4 + 2].setValue([ _tlx, _tly ]);
			if(inputs[| tool * 4 + 4].setValue([ _blx, _bly ])) UNDO_HOLDING = true;
		} else if(drag_side == tool * 4 + 4) {
			draw_line_width(br[0], br[1], tr[0], tr[1], 3);
			
			var _brx = value_snap(drag_s[0][0] + dx, _snx);
			var _bry = value_snap(drag_s[0][1] + dy, _sny);
								  
			var _trx = value_snap(drag_s[1][0] + dx, _snx);
			var _try = value_snap(drag_s[1][1] + dy, _sny);
			
			   inputs[| tool * 4 + 5].setValue([ _brx, _bry ]);
			if(inputs[| tool * 4 + 3].setValue([ _trx, _try ])) UNDO_HOLDING = true;
		} else if(drag_side == tool * 4 + 5) {
			draw_line_width(br[0], br[1], bl[0], bl[1], 3);
			
			var _brx = value_snap(drag_s[0][0] + dx, _snx);
			var _bry = value_snap(drag_s[0][1] + dy, _sny);
								  
			var _blx = value_snap(drag_s[1][0] + dx, _snx);
			var _bly = value_snap(drag_s[1][1] + dy, _sny);
			
			   inputs[| tool * 4 + 5].setValue([ _brx, _bry ]);
			if(inputs[| tool * 4 + 4].setValue([ _blx, _bly ])) UNDO_HOLDING = true;
		} else if(active) {
			draw_set_color(COLORS._main_accent);
			if(distance_to_line_infinite(_mx, _my, tl[0], tl[1], tr[0], tr[1]) < 12) {
				draw_line_width(tl[0], tl[1], tr[0], tr[1], 3);
				if(mouse_press(mb_left, active)) {
					drag_side = tool * 4 + 2;
					drag_mx = _mx;
					drag_my = _my;
					drag_s = [ current_data[tool * 4 + 2], current_data[tool * 4 + 3] ];
				}
			} else if(distance_to_line_infinite(_mx, _my, tl[0], tl[1], bl[0], bl[1]) < 12) {
				draw_line_width(tl[0], tl[1], bl[0], bl[1], 3);
				if(mouse_press(mb_left, active)) {
					drag_side = tool * 4 + 3;
					drag_mx = _mx;
					drag_my = _my;
					drag_s = [ current_data[tool * 4 + 2], current_data[tool * 4 + 4] ];
				}
			} else if(distance_to_line_infinite(_mx, _my, br[0], br[1], tr[0], tr[1]) < 12) {
				draw_line_width(br[0], br[1], tr[0], tr[1], 3);
				if(mouse_press(mb_left, active)) {
					drag_side = tool * 4 + 4;
					drag_mx = _mx;
					drag_my = _my;
					drag_s = [ current_data[tool * 4 + 5], current_data[tool * 4 + 3] ];
				}
			} else if(distance_to_line_infinite(_mx, _my, br[0], br[1], bl[0], bl[1]) < 12) {
				draw_line_width(br[0], br[1], bl[0], bl[1], 3);
				if(mouse_press(mb_left, active)) {
					drag_side = tool * 4 + 5;
					drag_mx = _mx;
					drag_my = _my;
					drag_s = [ current_data[tool * 4 + 5], current_data[tool * 4 + 4] ];
				}
			}
		}
		
		inputs[| tool * 4 + 2].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		inputs[| tool * 4 + 3].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		inputs[| tool * 4 + 4].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		inputs[| tool * 4 + 5].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var Ftl = _data[2];
		var Ftr = _data[3];
		var Fbl = _data[4];
		var Fbr = _data[5];
		
		var Ttl = _data[6];
		var Ttr = _data[7];
		var Tbl = _data[8];
		var Tbr = _data[9];
		
		var sw = surface_get_width(_data[0]);
		var sh = surface_get_height(_data[0]);
		
		surface_set_shader(_outSurf, sh_warp_4points_pers);
		shader_set_interpolation(_data[0]);
			shader_set_f("f1", Fbr[0] / sw, Fbr[1] / sh);
			shader_set_f("f2", Ftr[0] / sw, Ftr[1] / sh);
			shader_set_f("f3", Ftl[0] / sw, Ftl[1] / sh);
			shader_set_f("f4", Fbl[0] / sw, Fbl[1] / sh);
			
			shader_set_f("t1", Tbr[0] / sw, Tbr[1] / sh);
			shader_set_f("t2", Ttr[0] / sw, Ttr[1] / sh);
			shader_set_f("t3", Ttl[0] / sw, Ttl[1] / sh);
			shader_set_f("t4", Tbl[0] / sw, Tbl[1] / sh);
			
			draw_surface(_data[0], 0, 0);
		surface_reset_shader();
		
		return _outSurf;
	}
}