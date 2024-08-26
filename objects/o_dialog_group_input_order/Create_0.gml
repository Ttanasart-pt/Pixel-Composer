/// @description init
event_inherited();

#region data
	dialog_w = ui(320);
	dialog_h = ui(400);
	
	destroy_on_click_out = true;
	dragging    = noone;
	drag_disp   = noone;
	drag_insert = 0;
	drag_shift  = 0;
	
	sep_editing = -1;
	tb_edit = new textBox(TEXTBOX_INPUT.text, function(str) {
		if(sep_editing == -1) return;
		
		display_list[sep_editing][0] = str;
		sep_editing = -1;
		node.sortIO();
	} );
	tb_edit.align = fa_left;
	tb_edit.font  = f_p2;
	
	node          = noone;
	display_list  = [];
	type          = 1;
	junction_list = noone;
	
	function setNode(node, type) {
		self.node = node;
		self.type = type;
		self.display_list  = type == CONNECT_TYPE.input? node.attributes.input_display_list : node.attributes.output_display_list;
		self.junction_list = type == CONNECT_TYPE.input? node.inputs : node.outputs;
	}
#endregion

#region content
	sc_group = new scrollPane(dialog_w - ui(padding + padding), dialog_h - ui(title_height + padding), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		if(node == noone) return 0;
		
		var _h    = 0;
		var hg    = ui(28);
		var con_w = sc_group.surface_w;
		var hovr  = 0;
		var padd  = ui(4);
		
		for( var i = 0, n = array_length(display_list); i < n; i++ ) {
			var disp = display_list[i];
			
			var _y0 = _y;
			var _y1 = _y + hg + padd;
			
			if(dragging == noone) {
				var aa = 0.5;
				if(sHOVER && point_in_rectangle(_m[0], _m[1], 0 + padd, _y + padd, hg - padd, _y + hg - padd)) {
					sc_group.hover_content = true;
					aa = 1;
					if(mouse_press(mb_left, sFOCUS)) dragging = display_list[i];
				}
				
				draw_sprite_ui(THEME.hamburger_s, 0, hg / 2, _y + hg / 2,,,, COLORS._main_icon_light, aa);
			}
			
			if((i == n - 1 && _m[1] > _y0) || (_m[1] > _y0 && _m[1] <= _y1) || (i == 0 && _m[1] < _y1))
				hovr = i;
			
			if(is_array(disp)) {
				var ed_x = hg + ui(4);
				if(sHOVER && point_in_rectangle(_m[0], _m[1], ed_x, _y, con_w, _y + hg)) {
					draw_sprite_stretched_ext(THEME.button_def, 1, ed_x, _y, con_w - ed_x, hg, COLORS._main_icon_light, 1);
					
					if(sep_editing == -1 && mouse_press(mb_left, sFOCUS)) {
						sep_editing = i;
						tb_edit._current_text = disp[0];
						tb_edit.activate();
					}
				} else
					draw_sprite_stretched_ext(THEME.button_def, 0, ed_x, _y, con_w - ed_x, hg, COLORS._main_icon_light, 1);
				
				if(sep_editing == i) {
					WIDGET_CURRENT = tb_edit;
					tb_edit.setFocusHover(sFOCUS, sHOVER);
					tb_edit.draw(ed_x, _y, con_w - ed_x, hg, disp[0], _m);
				} else {
					draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
					draw_text_add(ed_x + ui(8), _y + hg / 2 - 1, disp[0]);
				}
			} else {
				var ind = junction_list[disp];
				draw_set_text(f_p2, fa_left, fa_center, ind.color_display);
				draw_text_add(hg + ui(8), _y + hg / 2 - 1, ind.name);
			}
			
			if(dragging == disp) {
				draw_sprite_ui(THEME.hamburger_s, 0, hg / 2, _y + hg / 2,,,, COLORS._main_accent, 1);
				draw_sprite_stretched_ext(THEME.button_hide, 3, 0, _y0, con_w, hg, COLORS._main_icon, 1);
			}
			
			_y += hg + padd;
			_h += hg + padd;
		}
		
		if(dragging != noone) {
			sc_group.hover_content = true;
			array_remove(display_list, dragging);
			array_insert(display_list, hovr, dragging);
			
			if(mouse_release(mb_left)) {
				node.sortIO();
				dragging = noone;
			}
		}
		
		return _h;
	})
#endregion