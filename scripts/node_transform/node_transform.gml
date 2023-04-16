enum OUTPUT_SCALING {
	same_as_input,
	constant,
	relative,
	scale
}

function Node_Transform(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Transform";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Output dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [1, 1])
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(false);
	
	inputs[| 2] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0.5, 0.5 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); }, VALUE_UNIT.reference);
	
	inputs[| 3] = nodeValue("Anchor", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0.5, 0.5 ])
		.setDisplay(VALUE_DISPLAY.vector, button(function() { centerAnchor(); })
											.setIcon(THEME.anchor)
											.setTooltip("Set to center"));
	
	inputs[| 4] = nodeValue("Relative anchor", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 5] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 6] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 7] = nodeValue("Tile", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Repeat the surface to fill the screen.");
	
	inputs[| 8] = nodeValue("Rotate by velocity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0, "Make the surface rotates to follow its movement.")
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 9] = nodeValue("Output dimension type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, OUTPUT_SCALING.same_as_input)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Same as input", "Constant", "Relative to input", "Scale" ]);
	
	inputs[| 10] = nodeValue("Round position", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Round position to the closest integer value to avoid jittering.");
	
	inputs[| 11] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 11;
		
	input_display_list = [ 11, 0, 
		["Output",		true],	9, 1, 7, 
		["Position",	false], 2, 10, 
		["Rotation",	false], 3, 5, 8, 
		["Scale",		false], 6
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	attribute_interpolation();
	
	vel = 0;
	prev_pos = [0, 0];
	
	static getDimension = function(arr) {
		var _surf		= getSingleValue(0, arr);
		var _out_type	= getSingleValue(9, arr);
		var _out		= getSingleValue(1, arr);
		var _scale		= getSingleValue(6, arr);
		var ww, hh;
		
		switch(_out_type) {
			case OUTPUT_SCALING.same_as_input :
				ww  = surface_get_width(_surf);
				hh  = surface_get_height(_surf);
				break;
			case OUTPUT_SCALING.relative : 
				ww  = surface_get_width(_surf)  * _out[0];
				hh  = surface_get_height(_surf) * _out[1];
				break;
			case OUTPUT_SCALING.constant :	
				ww  = _out[0];
				hh  = _out[1];
				break;
			case OUTPUT_SCALING.scale :	
				ww  = surface_get_width(_surf)  * _scale[0];
				hh  = surface_get_height(_surf) * _scale[1];
				break;
		}
		
		return [ww, hh];
	}
	
	static onValueUpdate = function(index, prev) {
		var curr = inputs[| 0].getValue();
	}
	
	static centerAnchor = function() {
		var _surf = inputs[| 0].getValue();
		
		var _out_type = inputs[| 9].getValue();
		var _out = inputs[| 1].getValue();
		var _sca = inputs[| 6].getValue();
		
		if(is_array(_surf)) {
			if(array_length(_surf) == 0) return;
			_surf = _surf[preview_index];
		}
		
		inputs[| 3].setValue([ 0.5, 0.5]);
		inputs[| 2].setValue([ surface_get_width(_surf) / 2, surface_get_height(_surf) / 2 ]);
	}
	
	static step = function() {
		var pos = inputs[| 2].getValue();
		
		if(!ANIMATOR.frame_progress) return;
		
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
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var ins = _data[0];
		
		var out_type = _data[9];
		var out = _data[1];
		
		var pos = _data[2];
		var pos_exact = _data[10];
		
		var anc = _data[3];
		
		var rot_vel = vel * _data[8];
		var rot = _data[5] + rot_vel;
		
		var sca = _data[6];
		var wrp = _data[7];
		
		var cDep = attrDepth();
		
		var ww  = surface_get_width(ins);
		var hh  = surface_get_height(ins);
		var _ww = ww, _hh = hh;
		if(_ww <= 1 && _hh <= 1) return _outSurf;
		
		switch(out_type) {
			case OUTPUT_SCALING.same_as_input :
				inputs[| 1].setVisible(false);
				break;
			case OUTPUT_SCALING.constant :	
				inputs[| 1].setVisible(true);
				_ww  = out[0];
				_hh  = out[1];
				break;
			case OUTPUT_SCALING.relative : 
				inputs[| 1].setVisible(true);
				_ww = ww * out[0];
				_hh = hh * out[1];
				break;
			case OUTPUT_SCALING.scale : 
				inputs[| 1].setVisible(false);
				_ww = ww * sca[0];
				_hh = hh * sca[1];
				break;
		}
		if(_ww <= 0 || _hh <= 0) return;
		_outSurf = surface_verify(_outSurf, _ww, _hh, cDep);
		
		anc[0] *= ww * sca[0];
		anc[1] *= hh * sca[1];
		
		pos[0] -= anc[0];
		pos[1] -= anc[1];
		
		pos = point_rotate(pos[0], pos[1], pos[0] + anc[0], pos[1] + anc[1], rot);
		
		if(wrp) {
			var _w = _ww * sqrt(2);
			var _h = _hh * sqrt(2);
			var _px = (_w - _ww) / 2;
			var _py = (_h - _hh) / 2;
			var _s = surface_create_valid(_w, _h, cDep);
			
			surface_set_target(_s);
				DRAW_CLEAR
				BLEND_OVERRIDE;
			
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
				
				BLEND_NORMAL;
			surface_reset_target();
			
			var _cc = point_rotate(-_px, -_py, _ww / 2, _hh / 2, rot);
			surface_set_shader(_outSurf);
			shader_set_interpolation(_s);
			draw_surface_ext_safe(_s, _cc[0], _cc[1], 1, 1, rot, c_white, 1);
			surface_reset_shader();
			
			surface_free(_s);
		} else {
			var draw_x, draw_y;
			draw_x = pos[0];
			draw_y = pos[1];
				
			if(pos_exact) {
				draw_x = round(draw_x);
				draw_y = round(draw_y);
			}
			
			surface_set_shader(_outSurf);	
			shader_set_interpolation(ins);
			draw_surface_ext_safe(ins, draw_x, draw_y, sca[0], sca[1], rot, c_white, 1);
			surface_reset_shader();
		}
		
		return _outSurf;
	}
	
	overlay_dragging = 0;
	corner_dragging  = 0;
	overlay_drag_mx  = 0;
	overlay_drag_my  = 0;
	overlay_drag_sx  = 0;
	overlay_drag_sy  = 0;
	overlay_drag_px  = 0;
	overlay_drag_py  = 0;
	overlay_drag_ma  = 0;
	overlay_drag_sa  = 0;
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(array_length(current_data) < ds_list_size(inputs)) return;
		
		var _surf = inputs[| 0].getValue();
		if(is_array(_surf)) {
			if(array_length(_surf) == 0) return;
			_surf = _surf[preview_index];
		}
		
		var _surf_out = outputs[| 0].getValue();
		if(is_array(_surf_out)) {
			if(array_length(_surf_out) == 0) return;
			_surf_out = _surf_out[preview_index];
		}
		
		var pos  = current_data[2];
		var _pos = [ pos[0], pos[1] ];
		
		var anc  = current_data[3];
		var _anc = [ anc[0], anc[1] ];
		
		var rot = current_data[5];
		var sca = current_data[6];
		
		var srw = surface_get_width(_surf);
		var srh = surface_get_height(_surf);
		
		var ow = surface_get_width(_surf_out);
		var oh = surface_get_height(_surf_out);
		
		var ww  = srw * sca[0];
		var hh  = srh * sca[1];
		
		anc[0] *= ww;
		anc[1] *= hh;
		
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
		
			draw_set_color(COLORS._main_accent);
			draw_sprite_colored(THEME.anchor, 0, bax, bay);
			
			var r_index = 0;
			
			draw_sprite_colored(THEME.anchor_selector, 0, tl[0], tl[1]);
			draw_sprite_colored(THEME.anchor_selector, 0, tr[0], tr[1]);
			draw_sprite_colored(THEME.anchor_selector, 0, bl[0], bl[1]);
			draw_sprite_colored(THEME.anchor_selector, 0, br[0], br[1]);
			
			     if(point_in_circle(_mx, _my, bax, bay, 8)) draw_sprite_colored(THEME.anchor, 0, bax, bay, 1.25);
			else if(point_in_circle(_mx, _my, rth[0], rth[1], 8)) r_index = 1;
			else if(point_in_circle(_mx, _my, tl[0], tl[1], 8))	draw_sprite_colored(THEME.anchor_selector, 1, tl[0], tl[1]);
			else if(point_in_circle(_mx, _my, tr[0], tr[1], 8))	draw_sprite_colored(THEME.anchor_selector, 1, tr[0], tr[1]);			
			else if(point_in_circle(_mx, _my, bl[0], bl[1], 8))	draw_sprite_colored(THEME.anchor_selector, 1, bl[0], bl[1]);			
			else if(point_in_circle(_mx, _my, br[0], br[1], 8))	draw_sprite_colored(THEME.anchor_selector, 1, br[0], br[1]);
			
			draw_sprite_colored(THEME.anchor_rotate, r_index, rth[0], rth[1], 1, rot);
			
			draw_line(tl[0], tl[1], tr[0], tr[1]);
			draw_line(tl[0], tl[1], bl[0], bl[1]);
			draw_line(tr[0], tr[1], br[0], br[1]);
			draw_line(bl[0], bl[1], br[0], br[1]);
			
		#endregion
		
		if(overlay_dragging && overlay_dragging < 3) { //Transform
			var px = _mx - overlay_drag_mx;
			var py = _my - overlay_drag_my;
			var pos_x, pos_y;
			
			if(key_mod_press(SHIFT)) {
				var ang  = round(point_direction(overlay_drag_mx, overlay_drag_my, _mx, _my) / 45) * 45;
				var dist = point_distance(overlay_drag_mx, overlay_drag_my, _mx, _my) / _s;
				
				pos_x = overlay_drag_sx + lengthdir_x(dist, ang);
				pos_y = overlay_drag_sy + lengthdir_y(dist, ang);
			} else {
				pos_x = overlay_drag_sx + px / _s;
				pos_y = overlay_drag_sy + py / _s;
			}
			
			pos_x = value_snap(pos_x, _snx);
			pos_y = value_snap(pos_y, _sny);
			
			if(overlay_dragging == 1) { //Move
				if(inputs[| 2].setValue([ pos_x, pos_y ]))
					UNDO_HOLDING = true;
			} else if(overlay_dragging == 2) { //Move anchor
				var nanx = pos_x / ww;
				var nany = pos_y / hh;
				
				if(key_mod_press(ALT)) {
					var modi = false;
					modi |= inputs[| 3].setValue([ nanx, nany ]);
					modi |= inputs[| 2].setValue([ overlay_drag_px + pos_x, overlay_drag_py + pos_y ]);
					
					if(modi)
						UNDO_HOLDING = true;
				} else {
					if(inputs[| 3].setValue([ nanx, nany ]))
						UNDO_HOLDING = true;
				}
			}
			
			if(mouse_release(mb_left)) {
				overlay_dragging = 0;	
				UNDO_HOLDING = false;
			}
		} else if(overlay_dragging == 3) { //Angle
			var aa = point_direction(bax, bay, _mx, _my);
			var da = angle_difference(overlay_drag_ma, aa);
			var sa;
			
			if(key_mod_press(CTRL)) 
				sa = round((overlay_drag_sa - da) / 15) * 15;
			else 
				sa = overlay_drag_sa - da;
			
			if(inputs[| 5].setValue(sa))
				UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				overlay_dragging = 0;
				UNDO_HOLDING = false;
			}
		} else if(overlay_dragging == 4) { //Scale
			var _p = point_rotate(_mx - overlay_drag_mx, _my - overlay_drag_my, 0, 0, -rot);
			
			var _sw = _p[0] / _s / srw;
			var _sh = _p[1] / _s / srh;
			var sw, sh;
			
			if(corner_dragging == 0) {
				sw = -_sw / _anc[0];
				sh = -_sh / _anc[1];
			} else if(corner_dragging == 1) {
				sw =  _sw / (1 - _anc[0]);
				sh = -_sh / _anc[1];
			} else if(corner_dragging == 2) {
				sw = -_sw / _anc[0];
				sh =  _sh / (1 - _anc[1]);
			} else if(corner_dragging == 3) {
				sw =  _sw / (1 - _anc[0]);
				sh =  _sh / (1 - _anc[1]);
			}
			
			var _sw = overlay_drag_sx + sw;
			var _sh = overlay_drag_sy + sh;
			
			if(key_mod_press(SHIFT)) {
				_sw = max(_sw, _sh);
				_sh = _sw;
			}
			
			if(inputs[| 6].setValue([ _sw, _sh ]))
				UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				overlay_dragging = 0;
				UNDO_HOLDING = false;
			}
		}
		
		if(overlay_dragging == 0 && mouse_press(mb_left, active)) {
			if(point_in_circle(_mx, _my, bax, bay, 8)) {
				overlay_dragging = 2;
				overlay_drag_mx  = _mx;
				overlay_drag_my  = _my;
				overlay_drag_sx  = anc[0];
				overlay_drag_sy  = anc[1];
				overlay_drag_px  = pos[0];
				overlay_drag_py  = pos[1];
			} else if(point_in_circle(_mx, _my, tl[0], tl[1], 8) || point_in_circle(_mx, _my, tr[0], tr[1], 8) || point_in_circle(_mx, _my, bl[0], bl[1], 8) || point_in_circle(_mx, _my, br[0], br[1], 8)) {
				overlay_dragging = 4;
				
				if(point_in_circle(_mx, _my, tl[0], tl[1], 8))		corner_dragging = 0;
				else if(point_in_circle(_mx, _my, tr[0], tr[1], 8)) corner_dragging = 1;
				else if(point_in_circle(_mx, _my, bl[0], bl[1], 8)) corner_dragging = 2;
				else if(point_in_circle(_mx, _my, br[0], br[1], 8)) corner_dragging = 3;
				
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
		
		#region path
			if(inputs[| 2].is_anim && inputs[| 2].value_from == noone && !inputs[| 2].sep_axis) {
				var posInp = inputs[| 2];
				var allPos = posInp.animator.values;
				var ox, oy, nx, ny;
			
				draw_set_color(COLORS._main_accent);
			
				for( var i = 0; i < ds_list_size(allPos); i++ ) {
					var _pos = allPos[| i].value;
					if(posInp.unit.mode == VALUE_UNIT.reference) {
						_pos[0] *= ow;
						_pos[1] *= oh;
					}
				
					nx = _x + _pos[0] * _s;
					ny = _y + _pos[1] * _s;
				
					draw_set_alpha(1);
					draw_circle(nx, ny, 4, false);
					if(i) {
						draw_set_alpha(0.5);
						draw_line_dashed(ox, oy, nx, ny);
					}
				
					ox = nx;
					oy = ny;
				}
			
				draw_set_alpha(1);
			}
		#endregion
	}
}