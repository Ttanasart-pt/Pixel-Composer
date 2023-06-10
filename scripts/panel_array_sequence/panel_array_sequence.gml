function Panel_Array_Sequence(node) : PanelContent() constructor {
	self.node = node;
	title = __txt("Array Sequence");
	
	w = ui(640);
	h = ui(168);
		
	padding = ui(16);
	
	content_h = ui(64);
	content_surface = noone;
	content_x       = 0;
	content_x_to    = 0;
	content_x_max   = 0;
	content_drag    = noone;
	
	sequence_surface = noone;
	sequence_x       = 0;
	sequence_x_to    = 0;
	sequence_x_max   = 0;
	sequence_drag    = noone;
	
	len_stretching = false;
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		var _seq = node.inputs[| 0].getValue();
		var _ord = node.inputs[| 2].getValue();
		
		var draw_drag = true;
		var content_w = w - (padding + padding);
		var _ns = content_h;
		var msx = mx - padding;
		var msy = my - padding;
		content_surface = surface_verify(content_surface, content_w, content_h);
		surface_set_target(content_surface);
			DRAW_CLEAR
			
			for( var i = 0; i < array_length(_seq); i++ ) {
				var _s  = _seq[i];
				if(!is_surface(_s)) continue;
				
				var _sx = content_x + i * (_ns + ui(8));
				var _sy = 0;
				var _sw = surface_get_width(_s);
				var _sh = surface_get_height(_s);
				var _ss = (_ns - ui(8)) / max(_sw, _sh);
				var _ssx = _sx + (_ns - _sw * _ss) / 2;
				var _ssy = _sy + (_ns - _sh * _ss) / 2;
				
				if(pHOVER && point_in_rectangle(msx, msy, _sx, _sy, _sx + _ns, _sy + _ns)) {
					draw_sprite_stretched(THEME.group_label, 1, _sx, _sy, _ns, _ns);
					if(mouse_press(mb_left, pFOCUS))
						content_drag = i;
				} else 
					draw_sprite_stretched(THEME.group_label, 0, _sx, _sy, _ns, _ns);
					
				draw_surface_ext_safe(_s, _ssx, _ssy, _ss, _ss);
			}
		surface_reset_target();
		
		content_x = lerp_float(content_x, content_x_to, 5);
		content_x_max = max(0, array_length(_seq) * (_ns + ui(8)) - content_w + ui(96));
		
		if(pHOVER && point_in_rectangle(mx, my, padding, padding, w - padding, h + content_h)) {
			if(mouse_wheel_down())	content_x_to = clamp(content_x_to - (_ns + ui(8)), -content_x_max, 0);
			if(mouse_wheel_up())	content_x_to = clamp(content_x_to + (_ns + ui(8)), -content_x_max, 0);
		}
		
		draw_surface(content_surface, padding, padding);
		
		var px = padding;
		var py = padding + content_h + ui(16);
		var pw = w - (padding + padding);
		var ph = h - (padding + padding) - content_h - ui(16);
		var _ns = ui(32);
		var len = array_length(_ord);
		var msx = mx - px;
		var msy = my - py;
		
		draw_sprite_stretched(THEME.ui_panel_bg, !in_dialog, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		sequence_surface = surface_verify(sequence_surface, pw, ph);
		surface_set_target(sequence_surface);
			DRAW_CLEAR
			
			draw_sprite_stretched(THEME.ui_panel_bg, 1, sequence_x, 0, len * _ns, ph);
			
			var ax = sequence_x + len * _ns + ui(12);
			var ay = ui(24) + _ns / 2;
			
			if(pHOVER && point_in_circle(msx, msy, ax, ay, ui(8))) {
				draw_sprite_ui(THEME.animation_stretch, 0, ax, ay,,,,, 1);
				if(mouse_press(mb_left, pFOCUS))
					len_stretching = true;
			} else 
				draw_sprite_ui(THEME.animation_stretch, 0, ax, ay,,,,, 0.75);
			
			for( var i = 0; i < ANIMATOR.frames_total; i++ ) {
				var _sx = sequence_x + i * _ns;
				
				draw_set_color(COLORS._main_text_sub);
				draw_set_alpha(0.5);
				draw_line(_sx, ui(24), _sx, ph);
				draw_set_alpha(1);
				
				draw_set_text(f_p2, fa_center, fa_top, COLORS._main_text_sub);
				draw_text_add(_sx + _ns / 2, ui(0), i);
			}
			
			for( var i = 0; i < array_length(_ord); i++ ) {
				var _i = _ord[i];
				if(_i == noone) continue;
				var _s = _seq[_i];
				if(!is_surface(_s)) continue;
				
				var _sx = sequence_x + i * _ns;
				var _sy = ui(24);
				var _sw = surface_get_width(_s);
				var _sh = surface_get_height(_s);
				var _ss = min(_ns / _sw, _ns / _sh);
				var _ssx = _sx + (_ns - _sw * _ss) / 2;
				var _ssy = _sy + (_ns - _sh * _ss) / 2;
				
				draw_surface_ext_safe(_s, _ssx, _ssy, _ss, _ss);
				
				if(pHOVER && point_in_rectangle(msx, msy, _sx, _sy, _sx + _ns, _sy + _ns)) {
					if(mouse_press(mb_left, pFOCUS)) {
						_ord[i] = noone;
						node.inputs[| 2].setValue(_ord);
						content_drag = _i;
					}
				}
			}
			
			if(content_drag != noone && pHOVER && point_in_rectangle(mx, my, px, py, px + pw, py + ph)) {
				var _s   = _seq[content_drag];
				var frm  = round((msx - sequence_x - _ns / 2) / _ns);
				var _sx  = sequence_x + frm * _ns;
				var _sy  = ui(24);
				var _sw  = surface_get_width(_s);
				var _sh  = surface_get_height(_s);
				var _ss  = min(_ns / _sw, _ns / _sh);
				var _ssx = _sx + (_ns - _sw * _ss) / 2;
				var _ssy = _sy + (_ns - _sh * _ss) / 2;
				
				draw_surface_ext_safe(_s, _ssx, _ssy, _ss, _ss,,, 0.75);
				draw_drag = false;
				
				if(mouse_release(mb_left, pFOCUS)) {
					_ord = array_safe_set(_ord, frm, content_drag, noone);
					node.inputs[| 2].setValue(_ord);
					content_drag = noone;
				}
			}
		surface_reset_target();
		
		sequence_x = lerp_float(sequence_x, sequence_x_to, 5);
		sequence_x_max = max(0, array_length(_ord) * _ns - pw + ui(320));
		
		if(pHOVER && point_in_rectangle(mx, my, px, py, px + pw, py + ph)) {
			if(mouse_wheel_down())	sequence_x_to = clamp(sequence_x_to - (_ns + ui(8)), -sequence_x_max, 0);
			if(mouse_wheel_up())	sequence_x_to = clamp(sequence_x_to + (_ns + ui(8)), -sequence_x_max, 0);
		}
		
		draw_surface(sequence_surface, px, py);
		
		if(len_stretching) {
			var frm  = round((msx - sequence_x - _ns / 2) / _ns);
			_ord = array_resize_fill(_ord, frm, noone);
			node.inputs[| 2].setValue(_ord);
			
			if(mouse_release(mb_left))
				len_stretching = false;
		}
		
		if(content_drag != noone) {
			if(draw_drag) {
				var _s  = _seq[content_drag];
				var _ns = content_h;
				var _sw = surface_get_width(_s);
				var _sh = surface_get_height(_s);
				var _ss = (_ns - ui(8)) / max(_sw, _sh);
				
				draw_surface_ext_safe(_s, mx, my, _ss, _ss,,, 0.5);
			}
			
			if(mouse_release(mb_left))
				content_drag = noone;
		}
	}
}