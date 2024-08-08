function Node_Transform_Single(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Transform single";
	
	inputs[0] = nodeValue_Surface("Surface in", self);
	
	inputs[1] = nodeValue_Float("Position x", self, 0);
	inputs[2] = nodeValue_Float("Position y", self, 0);
	inputs[3] = nodeValue_Float("Anchor x",   self, 0);
	inputs[4] = nodeValue_Float("Anchor y",   self, 0);
	inputs[5] = nodeValue_Float("Rotation",   self, 0);
	inputs[6] = nodeValue_Float("Scale x",    self, 1);
	inputs[7] = nodeValue_Float("Scale y",    self, 1);
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var pos_x = _data[1];
		var pos_y = _data[2];
		var anc_x = _data[3];
		var anc_y = _data[4];
		var rot   = _data[5];
		var sca_x = _data[6];
		var sca_y = _data[7];
		
		var psc_x = anc_x * sca_x;
		var psc_y = anc_y * sca_y;
		
		var origin = point_rotate(0, 0, anc_x, anc_y, rot);
		
		surface_set_target(_outSurf);
		DRAW_CLEAR
		BLEND_OVERRIDE;
		
		draw_surface_ext_safe(_data[0], pos_x + origin[0] - psc_x, pos_y + origin[1] - psc_y, sca_x, sca_y, rot, c_white, 1);
		
		BLEND_NORMAL;
		surface_reset_target();
		
		return _outSurf;
	}
	
	overlay_dragging = 0;
	overlay_drag_mx  = 0;
	overlay_drag_my  = 0;
	overlay_drag_sx  = 0;
	overlay_drag_sy  = 0;
	overlay_drag_ma  = 0;
	overlay_drag_sa  = 0;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		if(array_length(current_data) < array_length(inputs)) return;
		
		var _surf = outputs[0].getValue();
		if(is_array(_surf)) {
			if(array_length(_surf) == 0) return;
			_surf = _surf[preview_index];
		}
		
		var pos_x = current_data[1];
		var pos_y = current_data[2];
		var anc_x = current_data[3];
		var anc_y = current_data[4];
		var rot   = current_data[5];
		var sca_x = current_data[6];
		var sca_y = current_data[7];
		var ww  = surface_get_width_safe(_surf) * sca_x;
		var hh  = surface_get_height_safe(_surf) * sca_y;
		
		var psc_x = anc_x * sca_x;
		var psc_y = anc_y * sca_y;
		var _pos_x = pos_x;
		var _pos_y = pos_y;
		pos_x -= psc_x;
		pos_y -= psc_y;
		
		#region bounding box
			var bx0 = _x + pos_x * _s;
			var bx1 = _x + (ww + pos_x) * _s;
			var by0 = _y + pos_y * _s;
			var by1 = _y + (hh + pos_y) * _s;
		
			var bax = _x + (pos_x + anc_x) * _s;
			var bay = _y + (pos_y + anc_y) * _s;
			
			var tl = point_rotate(bx0, by0, bax, bay, rot);
			var tr = point_rotate(bx1, by0, bax, bay, rot);
			var bl = point_rotate(bx0, by1, bax, bay, rot);
			var br = point_rotate(bx1, by1, bax, bay, rot);
		
			draw_set_color(COLORS._main_accent);
			draw_sprite_colored(THEME.anchor, 0, bax, bay);
			
			draw_sprite_colored(THEME.anchor_selector, 0, tl[0], tl[1]);
			draw_sprite_colored(THEME.anchor_selector, 0, tr[0], tr[1]);
			draw_sprite_colored(THEME.anchor_selector, 0, bl[0], bl[1]);
			draw_sprite_colored(THEME.anchor_selector, 0, br[0], br[1]);
			
			if(point_in_circle(_mx, _my, bax, bay, 8))			draw_sprite_colored(THEME.anchor, 0, bax, bay, 1.25);
			else if(point_in_circle(_mx, _my, tl[0], tl[1], 8))	draw_sprite_colored(THEME.anchor_selector, 1, tl[0], tl[1]);
			else if(point_in_circle(_mx, _my, tr[0], tr[1], 8))	draw_sprite_colored(THEME.anchor_selector, 1, tr[0], tr[1]);			
			else if(point_in_circle(_mx, _my, bl[0], bl[1], 8))	draw_sprite_colored(THEME.anchor_selector, 1, bl[0], bl[1]);			
			else if(point_in_circle(_mx, _my, br[0], br[1], 8))	draw_sprite_colored(THEME.anchor_selector, 1, br[0], br[1]);
				
			draw_line(tl[0], tl[1], tr[0], tr[1]);
			draw_line(tl[0], tl[1], bl[0], bl[1]);
			draw_line(tr[0], tr[1], br[0], br[1]);
			draw_line(bl[0], bl[1], br[0], br[1]);
		#endregion
		
		if(overlay_dragging && overlay_dragging < 3) {
			var px = value_snap(_mx - overlay_drag_mx, _snx);
			var py = value_snap(_my - overlay_drag_my, _sny);
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
			
			if(key_mod_press(CTRL)) {
				pos_x = round(pos_x);
				pos_y = round(pos_y);
			}
			
			if(overlay_dragging == 1) {
				inputs[1].setValue(pos_x);
				inputs[2].setValue(pos_y);
			} else if(overlay_dragging == 2) {
				inputs[3].setValue(pos_x);
				inputs[4].setValue(pos_y);
			}
			
			if(mouse_release(mb_left))
				overlay_dragging = 0;	
		} else if(overlay_dragging == 3) {
			var aa = point_direction(bax, bay, _mx, _my);
			var da = angle_difference(overlay_drag_ma, aa);
			var sa = overlay_drag_sa - da;
			
			inputs[5].setValue(sa);
			
			if(mouse_release(mb_left))
				overlay_dragging = 0;	
		} else {
			if(mouse_press(mb_left, active)) {
				if(point_in_circle(_mx, _my, bax, bay, 8)) {
					overlay_dragging = 2;
					overlay_drag_mx  = _mx;
					overlay_drag_my  = _my;
					overlay_drag_sx  = anc_x;
					overlay_drag_sy  = anc_y;
				} else if(point_in_triangle(_mx, _my, tl[0], tl[1], tr[0], tr[1], bl[0], bl[1]) || point_in_triangle(_mx, _my, tr[0], tr[1], bl[0], bl[1], br[0], br[1])) {
					overlay_dragging = 1;
					overlay_drag_mx  = _mx;
					overlay_drag_my  = _my;
					overlay_drag_sx  = _pos_x;
					overlay_drag_sy  = _pos_y;
				} else if(point_in_circle(_mx, _my, tl[0], tl[1], 8) || point_in_circle(_mx, _my, tr[0], tr[1], 8) || point_in_circle(_mx, _my, bl[0], bl[1], 8) || point_in_circle(_mx, _my, br[0], br[1], 8)) {
					overlay_dragging = 3;
					overlay_drag_ma  = point_direction(bax, bay, _mx, _my);
					overlay_drag_sa  = rot;
				}
			}
		}
	}
}