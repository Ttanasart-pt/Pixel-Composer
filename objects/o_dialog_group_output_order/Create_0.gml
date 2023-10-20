/// @description init
event_inherited();

#region data
	dialog_w = ui(320);
	dialog_h = ui(400);
	
	destroy_on_click_out = true;
	dragging = noone;
	
	node = noone;
	display_list = [];
	
	function setNode(node) {
		self.node = node;
		self.display_list = node.output_display_list;
	}
	
	function refreshDisplay() {
		var _ord = 0;
			
		for( var i = 0, n = array_length(display_list); i < n; i++ ) {
			var ls = display_list[i];
				
			var _inp = node.outputs[| ls];
			_inp.from.attributes.input_priority = _ord;
			_ord++;
		}
		
		node.sortIO();
		display_list = node.output_display_list;
			
		PROJECT.modified = true;
	}
#endregion

#region content
	sc_group = new scrollPane(dialog_w - ui(padding + padding), dialog_h - ui(title_height + padding), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		if(node == noone) return 0;
		var _h    = 0;
		var hg    = ui(32);
		var con_w = sc_group.surface_w;
		var inpt  = 0;
		var hovr  = 0;
		var padd  = ui(4);
		var _drag = -1;
		var _ly   = _y;
		
		for( var i = 0, n = array_length(display_list); i < n; i++ ) {
			var disp = display_list[i];
			
			if(sHOVER && point_in_rectangle(_m[0], _m[1], 0 + padd, _y + padd, hg - padd, _y + hg - padd)) {
				draw_sprite_stretched_ext(THEME.group_label, 0, padd, _y + padd, hg - padd * 2, hg - padd * 2, COLORS._main_icon, 1);
					
				if(mouse_press(mb_left, sFOCUS))
					_drag = i;
			} else
				draw_sprite_stretched_ext(THEME.group_label, 0, padd, _y + padd, hg - padd * 2, hg - padd * 2, COLORS._main_icon_light, 1);
			draw_sprite_ui(THEME.hamburger, 0, hg / 2, _y + hg / 2, 0.5, 0.5,, COLORS._main_icon_light);
			
			if(dragging != noone && _m[1] > _y + ui(28)) {
				hovr = i + 1;
				_ly = _y + (is_array(disp)? hg : ui(28)) + ui(4);
			}
				
			var ind = node.outputs[| disp];
			draw_set_text(f_p0b, fa_left, fa_center, COLORS._main_text_sub);
			draw_text(hg + ui(8), _y + ui(14), ind.name);
				
			inpt++;
			_y += ui(28) + ui(4);
			_h += ui(28) + ui(4);
		}
		
		if(_drag > -1) {
			dragging = display_list[_drag];
			array_delete(display_list, _drag, 1);
		}
		
		if(dragging != noone && _ly > -1) {
			draw_set_color(COLORS._main_icon_dark);
			draw_line_round(ui(4), _ly, con_w - ui(4), _ly, 4);
		}
			
		if(dragging != noone && mouse_release(mb_left)) {
			array_insert(display_list, hovr, dragging);
			refreshDisplay();
			
			dragging = noone;
		}
		
		return _h;
	})
#endregion