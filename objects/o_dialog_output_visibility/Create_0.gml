/// @description init
event_inherited();

#region data
	dialog_w = ui(240);
	dialog_h = ui(320);
	
	node = noone;
	destroy_on_click_out = true;
	drag_height = ui(48);
	
	padding = ui(24);
	anchor = ANCHOR.left | ANCHOR.top;
	hold = false;
#endregion

#region content
	sc_outputs = new scrollPane(dialog_w - ui(padding + padding), dialog_h - ui(56 + padding), function(_y, _m) {
		draw_clear_alpha(COLORS._main_text, 0);
		if(node == noone) return 0;
		
		var hh = line_height() + ui(8);
		var _h = ds_list_size(node.outputs) * hh;
		
		for( var i = 0; i < ds_list_size(node.outputs); i++ ) {
			var output = node.outputs[| i];
			var _yy = _y + hh * i;
			
			if(sHOVER && sc_outputs.hover && point_in_rectangle(_m[0], _m[1], 0, _yy, sc_outputs.w, _yy + hh - 1)) {
				BLEND_OVERRIDE;
				draw_sprite_stretched(THEME.node_bg, 0, ui(2), _yy + ui(2), ui(32 - 4), hh - ui(4));
				BLEND_NORMAL;
				
				if(mouse_press(mb_left, sFOCUS)) {
					hold = !output.visible
					output.visible = hold;
				}
				
				if(mouse_click(mb_left, sFOCUS)) 
					output.visible = hold;
			}
			
			draw_sprite_ui(THEME.visible, output.visible, ui(16), _yy + hh / 2, 0.6, 0.6, 0, output.visible? COLORS._main_icon_light : COLORS._main_icon);
			
			draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
			draw_text_over(ui(36), _yy + hh / 2, output.name);
		}
		
		return _h;
	})
#endregion