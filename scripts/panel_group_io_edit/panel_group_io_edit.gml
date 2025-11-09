function Panel_Group_IO_Edit(_node, _type) : PanelContent() constructor {
	title = __txt("IO Editor");
	node  = _node;
	type  = _type;
	
	w = ui(320);
	h = ui(480);
	
	#region data
		dragging    = noone;
		drag_disp   = noone;
		drag_insert = 0;
		drag_shift  = 0;
		
		sep_editing = -1;
		tb_edit     = textBox_Text(function(str) /*=>*/ {
			if(sep_editing == -1) return;
			
			display_list[sep_editing][0] = str;
			sep_editing = -1;
			node.sortIO();
		}).setAlign(fa_left).setFont(f_p2);
		
		display_list  = type == CONNECT_TYPE.input? node.attributes.input_display_list : node.attributes.output_display_list;
		junction_list = type == CONNECT_TYPE.input? node.inputs : node.outputs;
	#endregion
	
	function addSection() {
		var _txt = "Separator";
		var _ind = 0;
		var _lst = node.attributes.input_display_list;
		
		while(array_exists(_lst, $"{_txt}{_ind}")) _ind++;
		
		array_push(node.attributes.input_display_list, [ $"{_txt}{_ind}", false ]);
		node.sortIO();
	}
	
	sp_content = new scrollPane(w - padding * 2, h - padding * 2, function(_y, _m) {
		draw_clear_alpha(CDEF.main_mdblack, 1);
		if(node == noone) return 0;
		
		var _h    = 0;
		var hg    = ui(28);
		var con_w = sp_content.surface_w;
		var hovr  = 0;
		var padd  = ui(4);
		var bs    = ui(24);
		var _del  = noone;
		
		var hov = sp_content.hover;
		var foc = sp_content.active;
		
		for( var i = 0, n = array_length(display_list); i < n; i++ ) {
			var disp = display_list[i];
			
			var _y0 = _y;
			var _y1 = _y + hg + padd;
			
			if(dragging == noone) {
				var aa = 0.5;
				if(hov && point_in_rectangle(_m[0], _m[1], 0 + padd, _y + padd, hg - padd, _y + hg - padd)) {
					sp_content.hover_content = true;
					aa = 1;
					if(mouse_press(mb_left, foc)) dragging = display_list[i];
				}
				
				draw_sprite_ui(THEME.hamburger_s, 0, hg / 2, _y + hg / 2,,,, COLORS._main_icon_light, aa);
			}
			
			if((i == n - 1 && _m[1] > _y0) || (_m[1] > _y0 && _m[1] <= _y1) || (i == 0 && _m[1] < _y1))
				hovr = i;
			
			if(is_array(disp)) {
				var ed_x = hg + ui(4);
				if(hov && point_in_rectangle(_m[0], _m[1], ed_x, _y, con_w - bs - ui(8), _y + hg)) {
					draw_sprite_stretched_ext(THEME.button_def, 1, ed_x, _y, con_w - ed_x, hg, COLORS._main_icon_light, 1);
					
					if(sep_editing == -1 && mouse_press(mb_left, foc)) {
						sep_editing = i;
						tb_edit._current_text = disp[0];
						tb_edit.activate();
					}
				} else
					draw_sprite_stretched_ext(THEME.button_def, 0, ed_x, _y, con_w - ed_x, hg, COLORS._main_icon_light, 1);
				
				if(sep_editing == i) {
					WIDGET_CURRENT = tb_edit;
					tb_edit.setFocusHover(foc, hov);
					tb_edit.draw(ed_x, _y, con_w - ed_x, hg, disp[0], _m);
					
				} else {
					draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
					draw_text_add(ed_x + ui(8), _y + hg / 2 - 1, disp[0]);
					
					if(buttonInstant(noone, con_w - ui(4) - bs, _y + hg / 2 - bs / 2 , bs, bs, _m, hov, foc, "", 
						THEME.icon_delete, 0, [ COLORS._main_icon, COLORS._main_value_negative ]) == 2)
						_del = i;
				}
				
			} else {
				var ind = junction_list[disp];
				draw_set_text(f_p2, fa_left, fa_center, ind.color_display);
				draw_text_add(hg + ui(8), _y + hg / 2 - 1, ind.name);
			}
			
			if(dragging == disp) {
				draw_sprite_ui(THEME.hamburger_s, 0, hg / 2, _y + hg / 2,,,, COLORS._main_accent, 1);
				draw_sprite_stretched_ext(THEME.button_hide_fill, 3, 0, _y0, con_w, hg, COLORS._main_icon, 1);
			}
			
			_y += hg + padd;
			_h += hg + padd;
		}
		
		if(_del != noone) {
			sp_content.hover_content = true;
			array_delete(display_list, _del, 1);
			node.sortIO();
		}
		
		if(dragging != noone) {
			sp_content.hover_content = true;
			array_remove(display_list, dragging);
			array_insert(display_list, hovr, dragging);
			
			if(mouse_release(mb_left)) {
				node.sortIO();
				dragging = noone;
			}
		}
		
		return _h;
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var px = padding;
		var py = padding;
		var pw = w - padding * 2;
		var ph = h - padding * 2;
		
		draw_sprite_stretched(THEME.ui_panel_bg,   1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		sp_content.verify(pw, ph);
		sp_content.setToolRect(type == CONNECT_TYPE.input? 1 : 0)
    	sp_content.setFocusHover(pFOCUS, pHOVER);
    	sp_content.drawOffset(px, py, mx, my);
    	
		var bs = ui(24);
		var bx = px + pw + ui(8) - bs;
		var by = py - ui(8);
		var bc = COLORS._main_value_positive;
		
		if(type == CONNECT_TYPE.input) { 
			var _txt = __txtx("dialog_group_order_add", "Add separator");
			if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, [mx, my], pHOVER, pFOCUS, _txt, THEME.add, 1, bc, 1, .75) == 2)
				addSection();
		}
	}
}