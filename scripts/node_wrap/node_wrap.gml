function Node_create_Warp(_x, _y) {
	var node = new Node_Warp(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Warp(_x, _y) : Node_Processor(_x, _y) constructor {
	name = "Warp";
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue(1, "Top left", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue(2, "Top right", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue(3, "Bottom left", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue(4, "Bottom right", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	drag_side = -1;
	drag_mx   = 0;
	drag_my   = 0;
	drag_sv   = 0;
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my) {
		if(array_length(current_data) < ds_list_size(inputs)) return;
		
		var _surf = outputs[| 0].getValue();
		if(is_array(_surf)) {
			if(array_length(_surf) == 0) return;
			_surf = _surf[preview_index];
		}
		
		var ww = surface_get_width(_surf);
		var hh = surface_get_height(_surf);
		var tl = current_data[1];
		var tr = current_data[2];
		var bl = current_data[3];
		var br = current_data[4];
		
		tl[0] = _x + tl[0] * ww * _s;
		tr[0] = _x + tr[0] * ww * _s;
		bl[0] = _x + bl[0] * ww * _s;
		br[0] = _x + br[0] * ww * _s;
		
		tl[1] = _y + tl[1] * hh * _s;
		tr[1] = _y + tr[1] * hh * _s;
		bl[1] = _y + bl[1] * hh * _s;
		br[1] = _y + br[1] * hh * _s;
		
		draw_set_color(COLORS._main_accent);
		draw_line(tl[0], tl[1], tr[0], tr[1]);
		draw_line(tl[0], tl[1], bl[0], bl[1]);
		draw_line(br[0], br[1], tr[0], tr[1]);
		draw_line(br[0], br[1], bl[0], bl[1]);
		
		if(inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my, ww, hh))
			active = false;
		if(inputs[| 2].drawOverlay(active, _x, _y, _s, _mx, _my, ww, hh))
			active = false;
		if(inputs[| 3].drawOverlay(active, _x, _y, _s, _mx, _my, ww, hh))
			active = false;
		if(inputs[| 4].drawOverlay(active, _x, _y, _s, _mx, _my, ww, hh))
			active = false;
		
		var dx = 0;
		var dy = 0;
		
		if(drag_side > -1) {
			dx = (_mx - drag_mx) / _s / ww;
			dy = (_my - drag_my) / _s / hh;
			drag_mx = _mx;
			drag_my = _my;
			
			if(mouse_release(mb_left)) {
				drag_side = -1;	
				UNDO_HOLDING = false;
			}
		}
		
		draw_set_color(COLORS.node_overlay_gizmo_inactive);
		if(drag_side == 0) {
			draw_line_width(tl[0], tl[1], tr[0], tr[1], 3);
			
			var _tlx = current_data[1][0] + dx;
			var _tly = current_data[1][1] + dy;
			
			var _trx = current_data[2][0] + dx;
			var _try = current_data[2][1] + dy;
			
			inputs[| 1].setValue([ _tlx, _tly ])
			if(inputs[| 2].setValue([ _trx, _try ])) UNDO_HOLDING = true;
		} else if(drag_side == 1) {
			draw_line_width(tl[0], tl[1], bl[0], bl[1], 3);
			
			var _tlx = current_data[1][0] + dx;
			var _tly = current_data[1][1] + dy;
			
			var _blx = current_data[3][0] + dx;
			var _bly = current_data[3][1] + dy;
			
			inputs[| 1].setValue([ _tlx, _tly ]);
			if(inputs[| 3].setValue([ _blx, _bly ])) UNDO_HOLDING = true;
		} else if(drag_side == 2) {
			draw_line_width(br[0], br[1], tr[0], tr[1], 3);
			
			var _brx = current_data[4][0] + dx;
			var _bry = current_data[4][1] + dy;
			
			var _trx = current_data[2][0] + dx;
			var _try = current_data[2][1] + dy;
			
			inputs[| 4].setValue([ _brx, _bry ]);
			if(inputs[| 2].setValue([ _trx, _try ])) UNDO_HOLDING = true;
		} else if(drag_side == 3) {
			draw_line_width(br[0], br[1], bl[0], bl[1], 3);
			
			var _brx = current_data[4][0] + dx;
			var _bry = current_data[4][1] + dy;
			
			var _blx = current_data[3][0] + dx;
			var _bly = current_data[3][1] + dy;
			
			inputs[| 4].setValue([ _brx, _bry ]);
			if(inputs[| 3].setValue([ _blx, _bly ])) UNDO_HOLDING = true;
		} else {
			draw_set_color(COLORS._main_accent);
			if(distance_to_line_infinite(_mx, _my, tl[0], tl[1], tr[0], tr[1]) < 12) {
				draw_line_width(tl[0], tl[1], tr[0], tr[1], 3);
				if(mouse_press(mb_left, active)) {
					drag_side = 0;
					drag_mx   = _mx;
					drag_my   = _my;
				}
			} else if(distance_to_line_infinite(_mx, _my, tl[0], tl[1], bl[0], bl[1]) < 12) {
				draw_line_width(tl[0], tl[1], bl[0], bl[1], 3);
				if(mouse_press(mb_left, active)) {
					drag_side = 1;
					drag_mx   = _mx;
					drag_my   = _my;
				}
			} else if(distance_to_line_infinite(_mx, _my, br[0], br[1], tr[0], tr[1]) < 12) {
				draw_line_width(br[0], br[1], tr[0], tr[1], 3);
				if(mouse_press(mb_left, active)) {
					drag_side = 2;
					drag_mx   = _mx;
					drag_my   = _my;
				}
			} else if(distance_to_line_infinite(_mx, _my, br[0], br[1], bl[0], bl[1]) < 12) {
				draw_line_width(br[0], br[1], bl[0], bl[1], 3);
				if(mouse_press(mb_left, active)) {
					drag_side = 3;
					drag_mx   = _mx;
					drag_my   = _my;
				}
			}
		}
	}
	
	static process_data = function(_outSurf, _data, _output_index) {
		var ww = surface_get_width(_data[0]);
		var hh = surface_get_height(_data[0]);
		var tl = _data[1];
		var tr = _data[2];
		var bl = _data[3];
		var br = _data[4];
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_ADD
			draw_set_color(c_white);
			
			var tex = surface_get_texture(_data[0]);
			draw_primitive_begin_texture(pr_trianglestrip, tex);
			
			var res = 4;
			var _i0, _i1, _j0, _j1;
			var tl_x = tl[0] * ww;
			var tl_y = tl[1] * hh;
			var tr_x = tr[0] * ww;
			var tr_y = tr[1] * hh;
			var bl_x = bl[0] * ww;
			var bl_y = bl[1] * hh;
			var br_x = br[0] * ww;
			var br_y = br[1] * hh;
			
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
		
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}