/// @description init
event_inherited();

#region data
	dialog_w = ui(320);
	dialog_h = ui(400);
	
	node = noone;
	destroy_on_click_out = true;
	
	sep_dragging = -1;
	
	sep_editing = -1;
	tb_edit = new textBox(TEXTBOX_INPUT.text, function(str) {
		if(sep_editing == -1) return;
		
		var sep = node.attributes[? "Separator"];
		sep[sep_editing][1] = str;
		node.attributes[? "Separator"] = sep;
		
		node.sortIO();
	} );
	tb_edit.align = fa_left;
#endregion

#region content
	sc_group = new scrollPane(dialog_w - ui(padding + padding), dialog_h - ui(title_height + padding), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		if(node == noone) return 0;
		var _h    = 0;
		var hg    = ui(32);
		var con_w = sc_group.surface_w;
		var inpt  = 0;
		var hovr  = -1;
		
		for( var i = 0; i < array_length(node.input_display_list); i++ ) {
			var disp = node.input_display_list[i];
			if(is_array(disp)) {
				if(sHOVER && point_in_rectangle(_m[0], _m[1], 0, _y, hg, _y + hg)) {
					draw_sprite_stretched_ext(THEME.group_label, 0, 0, _y, hg, hg, COLORS._main_icon, 1);
					
					if(mouse_press(mb_left, sFOCUS)) 
						sep_dragging = disp[2];
				} else
					draw_sprite_stretched_ext(THEME.group_label, 0, 0, _y, hg, hg, COLORS._main_icon_light, 1);
				
				var ed_x = hg + ui(4);
				if(sHOVER && point_in_rectangle(_m[0], _m[1], ed_x, _y, con_w, _y + hg)) {
					draw_sprite_stretched_ext(THEME.group_label, 0, ed_x, _y, con_w - ed_x, hg, COLORS._main_icon, 1);
					
					if(mouse_press(mb_left, sFOCUS)) {
						sep_editing = sep_editing == disp[2]? -1 : disp[2];
						if(sep_editing > -1)
							tb_edit.activate();
					}
				} else
					draw_sprite_stretched_ext(THEME.group_label, 0, ed_x, _y, con_w - ed_x, hg, COLORS._main_icon_light, 1);
				
				draw_sprite_ui(THEME.hamburger, 0, hg / 2, _y + hg / 2, 0.5, 0.5,, COLORS._main_icon_light);
				
				if(sep_editing == disp[2]) {
					var sep = node.attributes[? "Separator"];
					
					WIDGET_CURRENT = tb_edit;
					tb_edit.setActiveFocus(sFOCUS, sHOVER);
					tb_edit.draw(ed_x + ui(4), _y + ui(4), con_w - (ed_x + ui(8)), hg - ui(8), sep[sep_editing][1], mouse_ui);
					
					if(keyboard_check_pressed(vk_enter))
						sep_editing = -1;
				} else {
					draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
					draw_text(ed_x + ui(8), _y + hg / 2 - 1, disp[0]);
				}
				
				if(sep_dragging > -1 && point_in_rectangle(_m[0], _m[1], 0, _y - ui(4), con_w, _y + hg)) {
					draw_set_color(COLORS._main_icon_dark);
					draw_line_round(ui(4), _y, con_w - ui(4), _y, 4);
					
					hovr = inpt;
				}
				
				_y += hg + ui(4);
				_h += hg + ui(4);
			} else {
				var ind = node.inputs[| disp];
				draw_set_text(f_p0b, fa_left, fa_center, COLORS._main_text_sub);
				draw_text(ui(8), _y + ui(14), ind.name);
				
				if(sep_dragging > -1 && point_in_rectangle(_m[0], _m[1], 0, _y - ui(4), con_w, _y + ui(28))) {
					draw_set_color(COLORS._main_icon_dark);
					draw_line_round(ui(4), _y, con_w - ui(4), _y, 4);
					
					hovr = inpt;
				}
				
				inpt++;
				_y += ui(28) + ui(4);
				_h += ui(28) + ui(4);
			}
		}
		
		if(sep_dragging > -1 && hovr == -1) {
			hovr = ds_list_size(node.inputs) - node.custom_input_index
			draw_set_color(COLORS._main_icon_dark);
			draw_line_round(ui(4), _y, con_w - ui(4), _y, 4);
		}
			
		if(sep_dragging > -1 && mouse_release(mb_left)) {
			var sep = node.attributes[? "Separator"];
			sep[sep_dragging][0] = hovr;
			node.attributes[? "Separator"] = sep;
			node.sortIO();
				
			sep_dragging = -1;
		}
		
		return _h;
	})
#endregion