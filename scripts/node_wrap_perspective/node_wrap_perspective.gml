function Node_Warp_Perspective(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Perspective Warp";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Bool("Active", self, true));
		active_index = 1;
		
	newInput(2, nodeValue_Vec2("Top left", self, [ 0, 0 ] ))
		.setUnitRef(function(index) /*=>*/ {return getDimension(index)}, VALUE_UNIT.reference);
	
	newInput(3, nodeValue_Vec2("Top right", self, [ 1, 0 ] ))
		.setUnitRef(function(index) /*=>*/ {return getDimension(index)}, VALUE_UNIT.reference);
	
	newInput(4, nodeValue_Vec2("Bottom left", self, [ 0, 1 ] ))
		.setUnitRef(function(index) /*=>*/ {return getDimension(index)}, VALUE_UNIT.reference);
	
	newInput(5, nodeValue_Vec2("Bottom right", self, [ 1, 1 ] ))
		.setUnitRef(function(index) /*=>*/ {return getDimension(index)}, VALUE_UNIT.reference);
		
	newInput(6, nodeValue_Vec2("Top left", self, [ 0, 0 ] ))
		.setUnitRef(function(index) /*=>*/ {return getDimension(index)}, VALUE_UNIT.reference);
	
	newInput(7, nodeValue_Vec2("Top right", self, [ 1, 0 ] ))
		.setUnitRef(function(index) /*=>*/ {return getDimension(index)}, VALUE_UNIT.reference);
	
	newInput(8, nodeValue_Vec2("Bottom left", self, [ 0, 1 ] ))
		.setUnitRef(function(index) /*=>*/ {return getDimension(index)}, VALUE_UNIT.reference);
	
	newInput(9, nodeValue_Vec2("Bottom right", self, [ 1, 1 ] ))
		.setUnitRef(function(index) /*=>*/ {return getDimension(index)}, VALUE_UNIT.reference);
		
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1,
		["Surfaces", false], 0,
		["Warp",	 false], 6, 7, 8, 9,
	]
	
	attribute_surface_depth();
	attribute_interpolation();

	drag_side = -1;
	drag_mx   = 0;
	drag_my   = 0;
	drag_s    = [[0, 0], [0, 0]];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		if(array_length(current_data) < array_length(inputs)) return;
		
		var _surf = outputs[0].getValue();
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
		
		var tl = array_clone(current_data[tool * 4 + 2]);
		var tr = array_clone(current_data[tool * 4 + 3]);
		var bl = array_clone(current_data[tool * 4 + 4]);
		var br = array_clone(current_data[tool * 4 + 5]);
		
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
		
		if(inputs[tool * 4 + 2].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny)) active = false;
		if(inputs[tool * 4 + 3].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny)) active = false;
		if(inputs[tool * 4 + 4].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny)) active = false;
		if(inputs[tool * 4 + 5].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny)) active = false;
		
		var dx = 0;
		var dy = 0;
			
		draw_set_color(COLORS.node_overlay_gizmo_inactive);
		if(drag_side == tool * 4 + 2) {
			draw_line_width(tl[0], tl[1], tr[0], tr[1], 3);
			
			var _tlx = value_snap(drag_s[0][0] + dx, _snx);
			var _tly = value_snap(drag_s[0][1] + dy, _sny);
			
			var _trx = value_snap(drag_s[1][0] + dx, _snx);
			var _try = value_snap(drag_s[1][1] + dy, _sny);
			
			   inputs[tool * 4 + 2].setValue([ _tlx, _tly ])
			if(inputs[tool * 4 + 3].setValue([ _trx, _try ])) UNDO_HOLDING = true;
		} else if(drag_side == tool * 4 + 3) {
			draw_line_width(tl[0], tl[1], bl[0], bl[1], 3);
			
			var _tlx = value_snap(drag_s[0][0] + dx, _snx);
			var _tly = value_snap(drag_s[0][1] + dy, _sny);
								  
			var _blx = value_snap(drag_s[1][0] + dx, _snx);
			var _bly = value_snap(drag_s[1][1] + dy, _sny);
			
			   inputs[tool * 4 + 2].setValue([ _tlx, _tly ]);
			if(inputs[tool * 4 + 4].setValue([ _blx, _bly ])) UNDO_HOLDING = true;
		} else if(drag_side == tool * 4 + 4) {
			draw_line_width(br[0], br[1], tr[0], tr[1], 3);
			
			var _brx = value_snap(drag_s[0][0] + dx, _snx);
			var _bry = value_snap(drag_s[0][1] + dy, _sny);
								  
			var _trx = value_snap(drag_s[1][0] + dx, _snx);
			var _try = value_snap(drag_s[1][1] + dy, _sny);
			
			   inputs[tool * 4 + 5].setValue([ _brx, _bry ]);
			if(inputs[tool * 4 + 3].setValue([ _trx, _try ])) UNDO_HOLDING = true;
		} else if(drag_side == tool * 4 + 5) {
			draw_line_width(br[0], br[1], bl[0], bl[1], 3);
			
			var _brx = value_snap(drag_s[0][0] + dx, _snx);
			var _bry = value_snap(drag_s[0][1] + dy, _sny);
								  
			var _blx = value_snap(drag_s[1][0] + dx, _snx);
			var _bly = value_snap(drag_s[1][1] + dy, _sny);
			
			   inputs[tool * 4 + 5].setValue([ _brx, _bry ]);
			if(inputs[tool * 4 + 4].setValue([ _blx, _bly ])) UNDO_HOLDING = true;
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
		
		inputs[tool * 4 + 2].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		inputs[tool * 4 + 3].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		inputs[tool * 4 + 4].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		inputs[tool * 4 + 5].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var tl = _data[6];
		var tr = _data[7];
		var bl = _data[8];
		var br = _data[9];
		
		var sw = surface_get_width_safe(_data[0]);
		var sh = surface_get_height_safe(_data[0]);
		
		surface_set_shader(_outSurf, sh_warp_4points_pers);
		shader_set_interpolation(_data[0]);
			shader_set_f("t1", tl[0] / sw, tl[1] / sh);
			shader_set_f("t2", tr[0] / sw, tr[1] / sh);
			shader_set_f("t3", bl[0] / sw, bl[1] / sh);
			shader_set_f("t4", br[0] / sw, br[1] / sh);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		return _outSurf;
	}
}