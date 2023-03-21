function Node_Warp(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Warp";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Top left", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 2] = nodeValue("Top right", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ def_surf_size, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 3] = nodeValue("Bottom left", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, def_surf_size ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 4] = nodeValue("Bottom right", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ def_surf_size, def_surf_size ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 5] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 5;
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 5,
		["Surface",	 false], 0,
		["Wrap",	 false], 1, 2, 3, 4
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
		
		var tl = current_data[1];
		var tr = current_data[2];
		var bl = current_data[3];
		var br = current_data[4];
		
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
		
		if(inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny)) active = false;
		if(inputs[| 2].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny)) active = false;
		if(inputs[| 3].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny)) active = false;
		if(inputs[| 4].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny)) active = false;
		
		var dx = 0;
		var dy = 0;
		
		if(drag_side > -1) {
			dx = (_mx - drag_mx) / _s;
			dy = (_my - drag_my) / _s;
			
			if(mouse_release(mb_left)) {
				drag_side = -1;	
				UNDO_HOLDING = false;
			}
		}
		
		draw_set_color(COLORS.node_overlay_gizmo_inactive);
		if(drag_side == 0) {
			draw_line_width(tl[0], tl[1], tr[0], tr[1], 3);
			
			var _tlx = value_snap(drag_s[0][0] + dx, _snx);
			var _tly = value_snap(drag_s[0][1] + dy, _sny);
			
			var _trx = value_snap(drag_s[1][0] + dx, _snx);
			var _try = value_snap(drag_s[1][1] + dy, _sny);
			
			inputs[| 1].setValue([ _tlx, _tly ])
			if(inputs[| 2].setValue([ _trx, _try ])) UNDO_HOLDING = true;
		} else if(drag_side == 1) {
			draw_line_width(tl[0], tl[1], bl[0], bl[1], 3);
			
			var _tlx = value_snap(drag_s[0][0] + dx, _snx);
			var _tly = value_snap(drag_s[0][1] + dy, _sny);
								  
			var _blx = value_snap(drag_s[1][0] + dx, _snx);
			var _bly = value_snap(drag_s[1][1] + dy, _sny);
			
			inputs[| 1].setValue([ _tlx, _tly ]);
			if(inputs[| 3].setValue([ _blx, _bly ])) UNDO_HOLDING = true;
		} else if(drag_side == 2) {
			draw_line_width(br[0], br[1], tr[0], tr[1], 3);
			
			var _brx = value_snap(drag_s[0][0] + dx, _snx);
			var _bry = value_snap(drag_s[0][1] + dy, _sny);
								  
			var _trx = value_snap(drag_s[1][0] + dx, _snx);
			var _try = value_snap(drag_s[1][1] + dy, _sny);
			
			inputs[| 4].setValue([ _brx, _bry ]);
			if(inputs[| 2].setValue([ _trx, _try ])) UNDO_HOLDING = true;
		} else if(drag_side == 3) {
			draw_line_width(br[0], br[1], bl[0], bl[1], 3);
			
			var _brx = value_snap(drag_s[0][0] + dx, _snx);
			var _bry = value_snap(drag_s[0][1] + dy, _sny);
								  
			var _blx = value_snap(drag_s[1][0] + dx, _snx);
			var _bly = value_snap(drag_s[1][1] + dy, _sny);
			
			inputs[| 4].setValue([ _brx, _bry ]);
			if(inputs[| 3].setValue([ _blx, _bly ])) UNDO_HOLDING = true;
		} else if(active) {
			draw_set_color(COLORS._main_accent);
			if(distance_to_line_infinite(_mx, _my, tl[0], tl[1], tr[0], tr[1]) < 12) {
				draw_line_width(tl[0], tl[1], tr[0], tr[1], 3);
				if(mouse_press(mb_left, active)) {
					drag_side = 0;
					drag_mx = _mx;
					drag_my = _my;
					drag_s = [ current_data[1], current_data[2] ];
				}
			} else if(distance_to_line_infinite(_mx, _my, tl[0], tl[1], bl[0], bl[1]) < 12) {
				draw_line_width(tl[0], tl[1], bl[0], bl[1], 3);
				if(mouse_press(mb_left, active)) {
					drag_side = 1;
					drag_mx = _mx;
					drag_my = _my;
					drag_s = [ current_data[1], current_data[3] ];
				}
			} else if(distance_to_line_infinite(_mx, _my, br[0], br[1], tr[0], tr[1]) < 12) {
				draw_line_width(br[0], br[1], tr[0], tr[1], 3);
				if(mouse_press(mb_left, active)) {
					drag_side = 2;
					drag_mx = _mx;
					drag_my = _my;
					drag_s = [ current_data[4], current_data[2] ];
				}
			} else if(distance_to_line_infinite(_mx, _my, br[0], br[1], bl[0], bl[1]) < 12) {
				draw_line_width(br[0], br[1], bl[0], bl[1], 3);
				if(mouse_press(mb_left, active)) {
					drag_side = 3;
					drag_mx = _mx;
					drag_my = _my;
					drag_s = [ current_data[4], current_data[3] ];
				}
			}
		}
		
		inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		inputs[| 2].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		inputs[| 3].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		inputs[| 4].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var tl = _data[1];
		var tr = _data[2];
		var bl = _data[3];
		var br = _data[4];
		
		surface_set_shader(_outSurf);
		shader_set_interpolation(_data[0]);
			draw_set_color(c_white);
			
			var tex = surface_get_texture(_data[0]);
			draw_primitive_begin_texture(pr_trianglestrip, tex);
			
			var res = 4;
			var _i0, _i1, _j0, _j1;
			var tl_x = tl[0];
			var tl_y = tl[1];
			var tr_x = tr[0];
			var tr_y = tr[1];
			var bl_x = bl[0];
			var bl_y = bl[1];
			var br_x = br[0];
			var br_y = br[1];
			
			for( var i = 0; i < res; i++ ) {
				for( var j = 0; j < res; j++ ) {
					_i0 = i / res;
					_i1 = (i + 1) / res;
					_j0 = j / res;
					_j1 = (j + 1) / res;
					
					var _tlx = lerp(lerp(tl_x, tr_x, _i0), lerp(bl_x, br_x, _i0), _j0);
					var _tly = lerp(lerp(tl_y, tr_y, _i0), lerp(bl_y, br_y, _i0), _j0);
					var _trx = lerp(lerp(tl_x, tr_x, _i1), lerp(bl_x, br_x, _i1), _j0);
					var _try = lerp(lerp(tl_y, tr_y, _i1), lerp(bl_y, br_y, _i1), _j0);
					
					var _blx = lerp(lerp(tl_x, tr_x, _i0), lerp(bl_x, br_x, _i0), _j1);
					var _bly = lerp(lerp(tl_y, tr_y, _i0), lerp(bl_y, br_y, _i0), _j1);
					var _brx = lerp(lerp(tl_x, tr_x, _i1), lerp(bl_x, br_x, _i1), _j1);
					var _bry = lerp(lerp(tl_y, tr_y, _i1), lerp(bl_y, br_y, _i1), _j1);
					
					draw_vertex_texture(_tlx, _tly, _i0, _j0);
					draw_vertex_texture(_trx, _try, _i1, _j0);
					
					draw_vertex_texture(_blx, _bly, _i0, _j1);
					draw_vertex_texture(_brx, _bry, _i1, _j1);
				}
			}
			draw_primitive_end();
		surface_reset_shader();
		
		return _outSurf;
	}
}