function Node_create_Transform(_x, _y) {
	var node = new Node_Transform(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

enum OUTPUT_SCALING {
	same_as_input,
	constant,
	relative
}

function Node_Transform(_x, _y) : Node_Processor(_x, _y) constructor {
	name = "Transform";
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue(1, "Output dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [1, 1], VALUE_TAG.dimension_2d)
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(false, false);
	
	inputs[| 2] = nodeValue(2, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue(3, "Anchor", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector, button(function() { centerAnchor(); })
											.setIcon(s_anchor)
											.setTooltip("Set to center"));
	
	inputs[| 4] = nodeValue(4, "Relative", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true)
		.setVisible(false);
	
	inputs[| 5] = nodeValue(5, "Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 6] = nodeValue(6, "Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector, button(function() {
														inputs[| 6].modifier = inputs[| 6].modifier == VALUE_MODIFIER.none? VALUE_MODIFIER.linked : VALUE_MODIFIER.none;
														inputs[| 6].editWidget.extras.icon_index = inputs[| 6].modifier == VALUE_MODIFIER.linked;
													})
													.setIcon(s_padding_link));
	
	inputs[| 7] = nodeValue(7, "Wrap", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
		.setVisible(false);
	
	inputs[| 8] = nodeValue(8, "Rotate by velocity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 9] = nodeValue(9, "Output dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, OUTPUT_SCALING.same_as_input)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Same as input", "Constant", "Relative to input" ])
		.setVisible(false);
	
	inputs[| 10] = nodeValue(10, "Exact", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true)
		.setVisible(false);
	
	inputs[| 11] = nodeValue(11, "Relative to surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
		.setVisible(false);
	
	input_display_list = [ 0, 
		["Output",		true],	9, 1, 7, 
		["Position",	false], 11, 2, 10, 
		["Rotation",	false], 3, 4, 5, 8, 
		["Scale",		false], 6
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	vel = 0;
	prev_pos = [0, 0];
	
	static centerAnchor = function() {
		var _surf = inputs[| 0].getValue();
		
		var _out_type = inputs[| 9].getValue();
		var _out = inputs[| 1].getValue();
		var _sca = inputs[| 6].getValue();
		
		if(is_array(_surf)) {
			if(array_length(_surf) == 0) return;
			_surf = _surf[preview_frame];
		}
		
		var ww, hh;
		
		switch(_out_type) {
			case OUTPUT_SCALING.same_as_input :
			case OUTPUT_SCALING.relative : 
				ww  = surface_get_width(_surf)  * _sca[0];
				hh  = surface_get_height(_surf) * _sca[1];
				break;
			case OUTPUT_SCALING.constant :	
				ww  = _out[0] * _sca[0];
				hh  = _out[1] * _sca[1];
				break;
		}
		
		var _pos = inputs[| 3].getValue();
		
		if(inputs[| 4].getValue()) {
			if(_pos[0] != 0.5 && _pos[1] != 0.5)
				inputs[| 3].setValue([ 0.5, 0.5 ]);
			else
				inputs[| 3].setValue([ 0, 0 ]);
		} else {
			if(_pos[0] != ww / 2 && _pos[1] != hh / 2)
				inputs[| 3].setValue([ ww / 2, hh / 2]);
			else
				inputs[| 3].setValue([ 0, 0 ]);
		}
		
		if(inputs[| 11].getValue()) 
			inputs[| 2].setValue([ 0.5, 0.5 ]);
		else
			inputs[| 2].setValue([ surface_get_width(_surf) / 2, surface_get_height(_surf) / 2 ]);
	}
	
	function step() {
		var pos = inputs[| 2].getValue();
		
		if(ANIMATOR.is_playing && ANIMATOR.frame_progress) {
			if(ANIMATOR.current_frame == 0) {
				vel = 0;
				prev_pos[0] = pos[0];
				prev_pos[1] = pos[1];
			} else {
				vel = point_direction(prev_pos[0], prev_pos[1], pos[0], pos[1]);
				
				prev_pos[0] = pos[0];
				prev_pos[1] = pos[1];
			}
		}
	}
	
	function process_data(_outSurf, _data, _output_index) {
		var ins = _data[0];
		
		var out_type = _data[9];
		var out = _data[1];
		
		var pos_rel = _data[11];
		var pos = _data[2];
		var pos_exact = _data[10];
		
		var anc = _data[3];
		var arl = _data[4];
		
		var rot_vel = vel * _data[8];
		var rot = _data[5] + rot_vel;
		
		var sca = _data[6];
		var wrp = _data[7];
		
		var ww  = surface_get_width(ins);
		var hh  = surface_get_height(ins);
		var _ww = ww, _hh = hh;
		
		switch(out_type) {
			case OUTPUT_SCALING.same_as_input :
				node_input_visible(inputs[| 1], false);
				break;
			case OUTPUT_SCALING.constant :	
				node_input_visible(inputs[| 1], true);
				_ww  = out[0];
				_hh  = out[1];
				break;
			case OUTPUT_SCALING.relative : 
				node_input_visible(inputs[| 1], true);
				_ww = ww * out[0];
				_hh = hh * out[1];
				break;
		}
		if(_ww <= 0 || _hh <= 0) return;
		surface_size_to(_outSurf, _ww, _hh);
		
		if(arl) {
			anc[0] *= ww * sca[0];
			anc[1] *= hh * sca[1];
			
			if(pos_rel) {
				pos[0] *= ww;
				pos[1] *= hh;
			}
		}
		pos[0] -= anc[0];
		pos[1] -= anc[1];
		
		pos = point_rotate(pos[0], pos[1], pos[0] + anc[0], pos[1] + anc[1], rot);
		
		if(wrp) {
			var _w = _ww * sqrt(2);
			var _h = _hh * sqrt(2);
			var _px = (_w - _ww) / 2;
			var _py = (_h - _hh) / 2;
			var _s = surface_create(_w, _h);
			
			surface_set_target(_s);
				draw_clear_alpha(0, 0);
				BLEND_ADD
			
				if(is_surface(ins)) {
					var draw_x, draw_y;
					draw_x = _px + pos[0];
					draw_y = _py + pos[1];
				
					if(pos_exact) {
						draw_x = round(draw_x);
						draw_y = round(draw_y);
					}
					draw_surface_tiled_ext_safe(ins, draw_x, draw_y, sca[0], sca[1], c_white, 1);
				}
				
				BLEND_NORMAL
			surface_reset_target();
			
			var _cc = point_rotate(-_px, -_py, _ww / 2, _hh / 2, rot);
			surface_set_target(_outSurf);
				draw_clear_alpha(0, 0);
				BLEND_ADD
				
				draw_surface_ext_safe(_s, _cc[0], _cc[1], 1, 1, rot, c_white, 1);
				
				BLEND_NORMAL
			surface_reset_target();
			
			surface_free(_s);
		} else {
			surface_set_target(_outSurf);
				draw_clear_alpha(0, 0);
				BLEND_ADD
				
				var draw_x, draw_y;
				draw_x = pos[0];
				draw_y = pos[1];
				
				if(pos_exact) {
					draw_x = round(draw_x);
					draw_y = round(draw_y);
				}
				draw_surface_ext_safe(ins, draw_x, draw_y, sca[0], sca[1], rot, c_white, 1);
				
				BLEND_NORMAL
			surface_reset_target();
		}
		
		return _outSurf;
	}
	
	overlay_dragging = 0;
	overlay_drag_mx  = 0;
	overlay_drag_my  = 0;
	overlay_drag_sx  = 0;
	overlay_drag_sy  = 0;
	overlay_drag_ma  = 0;
	overlay_drag_sa  = 0;
	
	static drawOverlay = function(_active, _x, _y, _s, _mx, _my) {
		if(array_length(current_data) < ds_list_size(inputs)) return;
		
		var _surf = inputs[| 0].getValue();
		if(is_array(_surf)) {
			if(array_length(_surf) == 0) return;
			_surf = _surf[preview_frame];
		}
		
		var _surf_out = outputs[| 0].getValue();
		if(is_array(_surf_out)) {
			if(array_length(_surf_out) == 0) return;
			_surf_out = _surf_out[preview_frame];
		}
		
		var pos = current_data[2];
		var pos_rel = current_data[11];
		
		var anc = current_data[3];
		var arl = current_data[4];
		
		var rot = current_data[5];
		var sca = current_data[6];
		
		var srw = surface_get_width(_surf);
		var srh = surface_get_height(_surf);
		
		var ow = surface_get_width(_surf_out);
		var oh = surface_get_height(_surf_out);
		
		var ww  = srw * sca[0];
		var hh  = srh * sca[1];
		
		if(arl) {
			anc[0] *= ww;
			anc[1] *= hh;
		}
		
		if(pos_rel) {
			pos[0] *= ow;
			pos[1] *= oh;	
		}
		
		var _pos  = [ pos[0], pos[1] ];
		pos[0] -= anc[0];
		pos[1] -= anc[1];
		
		#region bounding box
			var bx0 = _x + pos[0] * _s;
			var bx1 = _x + (ww + pos[0]) * _s;
			var by0 = _y + pos[1] * _s;
			var by1 = _y + (hh + pos[1]) * _s;
		
			var bax = _x + (pos[0] + anc[0]) * _s;
			var bay = _y + (pos[1] + anc[1]) * _s;
			
			var tl = point_rotate(bx0, by0, bax, bay, rot);
			var tr = point_rotate(bx1, by0, bax, bay, rot);
			var bl = point_rotate(bx0, by1, bax, bay, rot);
			var br = point_rotate(bx1, by1, bax, bay, rot);
			
			var rth = point_rotate((bx0 + bx1) / 2, by0 - 16, bax, bay, rot);
		
			draw_set_color(c_ui_orange);
			draw_sprite_ext(s_anchor, 0, bax, bay, 1, 1, 0, c_white, 1);
			
			var r_index = 0;
			
			draw_sprite(s_anchor_selector, 0, tl[0], tl[1]);
			draw_sprite(s_anchor_selector, 0, tr[0], tr[1]);
			draw_sprite(s_anchor_selector, 0, bl[0], bl[1]);
			draw_sprite(s_anchor_selector, 0, br[0], br[1]);
			
			if(point_in_circle(_mx, _my, bax, bay, 8)) draw_sprite_ext(s_anchor, 0, bax, bay, 1.25, 1.25, 0, c_white, 1);
			else if(point_in_circle(_mx, _my, rth[0], rth[1], 8)) r_index = 1;
			else if(point_in_circle(_mx, _my, tl[0], tl[1], 8))	draw_sprite(s_anchor_selector, 1, tl[0], tl[1]);
			else if(point_in_circle(_mx, _my, tr[0], tr[1], 8))	draw_sprite(s_anchor_selector, 1, tr[0], tr[1]);			
			else if(point_in_circle(_mx, _my, bl[0], bl[1], 8))	draw_sprite(s_anchor_selector, 1, bl[0], bl[1]);			
			else if(point_in_circle(_mx, _my, br[0], br[1], 8))	draw_sprite(s_anchor_selector, 1, br[0], br[1]);
			
			draw_sprite_ext(s_anchor_rotate, r_index, rth[0], rth[1], 1, 1, rot, c_white, 1);
			
			draw_line(tl[0], tl[1], tr[0], tr[1]);
			draw_line(tl[0], tl[1], bl[0], bl[1]);
			draw_line(tr[0], tr[1], br[0], br[1]);
			draw_line(bl[0], bl[1], br[0], br[1]);
			
		#endregion
		
		if(overlay_dragging && overlay_dragging < 3) {
			var px = _mx - overlay_drag_mx;
			var py = _my - overlay_drag_my;
			var pos_x, pos_y;
			
			if(keyboard_check(vk_shift)) {
				var ang  = round(point_direction(overlay_drag_mx, overlay_drag_my, _mx, _my) / 45) * 45;
				var dist = point_distance(overlay_drag_mx, overlay_drag_my, _mx, _my) / _s;
				
				pos_x = overlay_drag_sx + lengthdir_x(dist, ang);
				pos_y = overlay_drag_sy + lengthdir_y(dist, ang);
			} else {
				pos_x = overlay_drag_sx + px / _s;
				pos_y = overlay_drag_sy + py / _s;
			}
			
			if(keyboard_check(vk_control)) {
				pos_x = round(pos_x);
				pos_y = round(pos_y);
			}
			
			if(overlay_dragging == 1) {
				if(pos_rel) {
					pos_x /= ow;
					pos_y /= oh;
				}
			
				if(inputs[| 2].setValue([ pos_x, pos_y ]))
					UNDO_HOLDING = true;
			} else if(overlay_dragging == 2) {
				if(arl) { 
					pos_x /= ww;
					pos_y /= hh;
				}
				
				if(inputs[| 3].setValue([ pos_x, pos_y ]))
					UNDO_HOLDING = true;
			}
			
			if(mouse_check_button_released(mb_left)) {
				overlay_dragging = 0;	
				UNDO_HOLDING = false;
			}
		} else if(overlay_dragging == 3) {
			var aa = point_direction(bax, bay, _mx, _my);
			var da = angle_difference(overlay_drag_ma, aa);
			var sa;
			
			if(keyboard_check(vk_control)) 
				sa = round((overlay_drag_sa - da) / 15) * 15;
			else 
				sa = overlay_drag_sa - da;
			
			if(inputs[| 5].setValue(sa))
				UNDO_HOLDING = true;
			
			if(mouse_check_button_released(mb_left)) {
				overlay_dragging = 0;
				UNDO_HOLDING = false;
			}
		} else if(overlay_dragging == 4) {
			var _dist = point_distance (overlay_drag_mx, overlay_drag_my, bax, bay);
			var _dirr = point_direction(overlay_drag_mx, overlay_drag_my, bax, bay);
			
			var dist = point_distance (_mx, _my, bax, bay);
			var dirr = point_direction(_mx, _my, bax, bay);
			
			var sw = (lengthdir_x(dist, dirr) - lengthdir_x(_dist, _dirr)) / _s / srw;
			var sh = (lengthdir_y(dist, dirr) - lengthdir_y(_dist, _dirr)) / _s / srh;
			
			var _sw = overlay_drag_sx - sw;
			var _sh = overlay_drag_sy - sh;
			
			if(keyboard_check(vk_shift)) {
				_sw = max(_sw, _sh);
				_sh = _sw;
			}
			
			if(inputs[| 6].setValue([ _sw, _sh ]))
				UNDO_HOLDING = true;
			
			if(mouse_check_button_released(mb_left)) {
				overlay_dragging = 0;
				UNDO_HOLDING = false;
			}
		} else {
			if(_active && mouse_check_button_pressed(mb_left)) {
				if(point_in_circle(_mx, _my, bax, bay, 8)) {
					overlay_dragging = 2;
					overlay_drag_mx  = _mx;
					overlay_drag_my  = _my;
					overlay_drag_sx  = anc[0];
					overlay_drag_sy  = anc[1];
				} else if(point_in_circle(_mx, _my, tl[0], tl[1], 8) || point_in_circle(_mx, _my, tr[0], tr[1], 8) || point_in_circle(_mx, _my, bl[0], bl[1], 8) || point_in_circle(_mx, _my, br[0], br[1], 8)) {
					overlay_dragging = 4;
					overlay_drag_mx  = _mx;
					overlay_drag_my  = _my;
					overlay_drag_sx  = sca[0];
					overlay_drag_sy  = sca[1];
				} else if(point_in_circle(_mx, _my, rth[0], rth[1], 8)) {
					overlay_dragging = 3;
					overlay_drag_ma  = point_direction(bax, bay, _mx, _my);
					overlay_drag_sa  = rot;
				} else if(point_in_triangle(_mx, _my, tl[0], tl[1], tr[0], tr[1], bl[0], bl[1]) || point_in_triangle(_mx, _my, tr[0], tr[1], bl[0], bl[1], br[0], br[1])) {
					overlay_dragging = 1;
					overlay_drag_mx  = _mx;
					overlay_drag_my  = _my;
					overlay_drag_sx  = _pos[0];
					overlay_drag_sy  = _pos[1];
				}
			}
		}
	}
}