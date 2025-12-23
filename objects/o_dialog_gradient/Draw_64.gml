/// @description init
if !ready exit;
draggable = true;

#region dropper
	selector.interactable = interactable;
	if(selector.dropper_active) {
		selector.drawDropper(self);
		exit;
	}
#endregion

#region base UI
	var presets_x  = dialog_x;
	var presets_w  = ui(240);
	
	var content_x = dialog_x + presets_w + ui(16);
	var content_w = ui(556);
	
	var palette_x  = content_x + content_w + ui(16);
	var palette_w  = ui(240);
	
	var p  = DIALOG_PAD;
	var p2 = DIALOG_PAD * 2;
	
	draw_sprite_stretched(THEME.dialog, 0, presets_x - p, dialog_y - p, presets_w + p2, dialog_h + p2);
	if(sFOCUS) draw_sprite_stretched_ext(THEME.dialog, 1, presets_x - p, dialog_y - p, presets_w + p2, dialog_h + p2, COLORS._main_accent, 1);
	
	draw_sprite_stretched(THEME.dialog, 0, content_x - p, dialog_y - p, content_w + p2, dialog_h + p2);
	if(sFOCUS) draw_sprite_stretched_ext(THEME.dialog, 1, content_x - p, dialog_y - p, content_w + p2, dialog_h + p2, COLORS._main_accent, 1);
	
	draw_sprite_stretched(THEME.dialog, 0, palette_x - p, dialog_y - p, presets_w + p2, dialog_h + p2);
	if(sFOCUS) draw_sprite_stretched_ext(THEME.dialog, 1, palette_x - p, dialog_y - p, presets_w + p2, dialog_h + p2, COLORS._main_accent, 1);
	
	draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text);
	draw_text(presets_x + ui(24), dialog_y + ui(16), __txt("Presets"));
	draw_text(content_x + (!interactable * ui(32)) + ui(24), dialog_y + ui(16), name);
	if(!interactable)
		draw_sprite_ui(THEME.lock, 0, content_x + ui(24 + 12), dialog_y + ui(16 + 12),,,, COLORS._main_icon);
	draw_text(palette_x + ui(24), dialog_y + ui(16), __txt("Palettes"));
#endregion

#region presets
	draw_sprite_stretched(THEME.ui_panel_bg, 1, presets_x + pal_padding, dialog_y + ui(48), ui(240) - pal_padding * 2, dialog_h - ui(48) - pal_padding);
	
	var _px = presets_x + pal_padding + ui(4);
	var _py = dialog_y + ui(48 + 4);
	var _pw = sp_palette_w;
	
	draw_sprite_stretched_ext(THEME.textbox, 1, _px, _py, _pw, ui(24), COLORS._main_icon);
	tb_preset_search.setFocusHover(sFOCUS, sHOVER);
	tb_preset_search.draw(_px, _py, _pw, ui(24), gradient_search_string);
	draw_sprite_ui(THEME.search, 0, _px + ui(12), _py + ui(12), .75, .75, 0, COLORS._main_icon, .5);
	
	sp_presets.setFocusHover(sFOCUS, sHOVER);
	sp_presets.verify(_pw, dialog_h - ui(72 + 24));
	sp_presets.draw(_px, _py + ui(24 + 8));
	
	var bs  = ui(24);
	var bx  = presets_x + presets_w - bs - ui(12);
	var by  = dialog_y + ui(14);
	var bb  = THEME.button_hide_fill;
	var hov = sHOVER, foc = sFOCUS;
	var m   = mouse_ui;
	var bc  = COLORS._main_icon;
	
	var bt = __txtx("add_preset", "Add to preset");
	var b  = buttonInstant_Pad(bb, bx, by, bs, bs, m, hov, foc, bt, THEME.add);
	if(b == 2) {
		var dia = dialogCall(o_dialog_file_name, mouse_mx + ui(8), mouse_my + ui(8));
		dia.onModify = function (txt) {
			var gradStr = "";
			
			for(var i = 0; i < array_length(gradient.keys); i++) {
				var gr = gradient.keys[i];
				gradStr += $"{gr.value},{gr.time}\n";
			}
			
			file_text_write_all(txt + ".txt", gradStr);
			__initGradient();
		};
		dia.path = DIRECTORY + "Gradients/"
	}
	draggable = draggable && !b;
	bx -= bs + ui(2);
	
	var b = buttonInstant_Pad(bb, bx, by, bs, bs, m, hov, foc, __txt("View settings..."), THEME.sort_v);
	if(b == 2) with menuCall("", menu_grad_preset_sort, bx + bs, by + bs) close_on_trigger = false;
	draggable = draggable && !b;
	bx -= bs + ui(2);
	
	var bt = __txt("Refresh");
	var b  = buttonInstant_Pad(bb, bx, by, bs, bs, m, hov, foc, bt, THEME.refresh_icon);
	if(b == 2) { __initGradient(); }
	draggable = draggable && !b;
	bx -= bs + ui(2);
	
	var bt = __txtx("graident_editor_open_folder", "Open gradient folder");
	var b  = buttonInstant_Pad(bb, bx, by, bs, bs, m, hov, foc, bt, THEME.dPath_open_20, 0, bc, 1, 0);
	if(b == 2) {
		var _realpath = DIRECTORY + "Gradients";
		shellOpenExplorer(_realpath)
	}
	draggable = draggable && !b;
	bx -= bs + ui(2);
#endregion

#region palette
	draw_sprite_stretched(THEME.ui_panel_bg, 1, palette_x + pal_padding, dialog_y + ui(48), ui(240) - pal_padding * 2, dialog_h - ui(48) - pal_padding);
	
	var _px = palette_x + pal_padding + ui(4);
	var _py = dialog_y + ui(48 + 4);
	var _pw = sp_palette_w;
	
	draw_sprite_stretched_ext(THEME.textbox, 1, _px, _py, _pw, ui(24), COLORS._main_icon);
	tb_palette_search.setFocusHover(sFOCUS, sHOVER);
	tb_palette_search.draw(_px, _py, _pw, ui(24), palette_search_string);
	draw_sprite_ui(THEME.search, 0, _px + ui(12), _py + ui(12), .75, .75, 0, COLORS._main_icon, .5);
	
	sp_palettes.setFocusHover(sFOCUS, sHOVER);
	sp_palettes.verify(_pw, dialog_h - ui(72 + 24));
	sp_palettes.draw(_px, _py + ui(24 + 8));
	
	var bs  = ui(24);
	var bx  = palette_x + palette_w - bs - ui(12);
	var by  = dialog_y + ui(14);
	var bb  = THEME.button_hide_fill;
	var hov = sHOVER, foc = sFOCUS;
	var m   = mouse_ui;
	var bc  = COLORS._main_icon;
	
	var t = __txt("Show on Selector");
	var b = buttonInstant_Pad(bb, bx, by, bs, bs, m, hov, foc, t, THEME.display_palette, NODE_COLOR_SHOW_PALETTE, c_white);
	if(b == 2) NODE_COLOR_SHOW_PALETTE = !NODE_COLOR_SHOW_PALETTE;
	draggable = draggable && !b;
	bx -= bs + ui(2);
	
	var b = buttonInstant_Pad(bb, bx, by, bs, bs, m, hov, foc, __txt("View settings..."), THEME.sort_v);
	if(b == 2) with menuCall("", menu_preset_sort, bx + bs, by + bs) close_on_trigger = false;
	draggable = draggable && !b;
	bx -= bs + ui(2);
	
#endregion

#region gradient tools
	var _hov = sHOVER;
	var _foc = interactable && sFOCUS;
	
	var bs  = ui(24);
	var bx = content_x + content_w - ui(12);
	var by = dialog_y + ui(14);
	
	var sw = ui(104);
	var tt = gradient.type < 2? !gradient.type : gradient.type; 
	bx -= sw;
	sb_blending.setFocusHover(foc, hov);
	sb_blending.draw(bx, by, sw, bs, tt);
	bx -= bs + ui(4);
	
	// var t = __txtx("gradient_editor_key_blend", "Key blending...");
	// var b = buttonInstant_Pad(bb, bx, by, bs, bs, m, _hov, _foc, t, THEME.dGradient_keys_blend, 0, bc, 1, 0);
	// draggable = draggable && !b;
	
	// if(b == 2) {
	// 	menuCall("gradient_window_blend_menu", [ 
	// 		menuItem(__txtx("gradient_editor_blend_hard",  "Solid"), () => { gradient.type = 1; onApply(gradient); }), 
	// 		menuItem(__txtx("gradient_editor_blend_RGB",   "RGB"),   () => { gradient.type = 0; onApply(gradient); }), 
	// 		menuItem(__txtx("gradient_editor_blend_HSV",   "HSV"),   () => { gradient.type = 2; onApply(gradient); }), 
	// 		menuItem(__txtx("gradient_editor_blend_OKLAB", "OKLAB"), () => { gradient.type = 3; onApply(gradient); }), 
	// 	], bx + ui(32), by, fa_left, gradient);
	// }
	// bx -= bs + ui(2);
	
	var t = __txtx("gradient_editor_reverse", "Reverse");
	var b = buttonInstant_Pad(bb, bx, by, bs, bs, m, _hov, _foc, t, THEME.dGradient_keys_reverse, 0, bc, 1, 0);
	draggable = draggable && !b;
	
	if(b == 2) {
		for( var i = 0, n = array_length(gradient.keys); i < n; i++ )
			gradient.keys[i].time = 1 - gradient.keys[i].time;
		gradient.keys = array_reverse(gradient.keys);
		onApply(gradient);
	}
	bx -= bs + ui(2);
	
	var t = __txt("Distribute");
	var b = buttonInstant_Pad(bb, bx, by, bs, bs, m, _hov, _foc, t, THEME.dGradient_keys_distribute, 0, bc, 1, 0);
	draggable = draggable && !b;
	
	if(b == 2) {
		var _stp = 1 / (array_length(gradient.keys) - (gradient.type != 1));
		
		for( var i = 0, n = array_length(gradient.keys); i < n; i++ )
			gradient.keys[i].time = _stp * i;
		onApply(gradient);
	}
	bx -= bs + ui(2);
#endregion

#region gradient
	var gr_x = content_x + ui(22);
	var gr_y = dialog_y + ui(54);
	var gr_w = content_w - ui(44);
	var gr_h = ui(20);
	draw_sprite_stretched(THEME.textbox, 3, gr_x - ui(6), gr_y - ui(6), gr_w + ui(12), gr_h + ui(12));
	draw_sprite_stretched(THEME.textbox, 0, gr_x - ui(6), gr_y - ui(6), gr_w + ui(12), gr_h + ui(12));
	gradient.draw(gr_x, gr_y, gr_w, gr_h);
	draw_sprite_stretched_add(THEME.ui_panel, 1, gr_x, gr_y, gr_w, gr_h, c_white, 0.25);
	
	var hover = noone;
	
	for( var i = 0, n = array_length(gradient.keys); i < n; i++ ) {
		var _k  = gradient.keys[i];
		var _c  = _k.value;
		var _kx = gr_x + _k.time * gr_w; 
		var _ky = gr_y + gr_h / 2;
		
		var _hov  = sHOVER && point_in_rectangle(mouse_mx, mouse_my, _kx - ui(6), gr_y, _kx + ui(6), gr_y + gr_h);
		    _hov = _hov || key_dragging == _k;
		_k._hover = lerp_float(_k._hover, _hov || key_selecting == _k, 5);
		
		var _kw = ui(10);
		var _kh = lerp(ui(10), ui(32), _k._hover);
		
		var _kdx = _kx - _kw / 2;
		var _kdy = _ky - _kh / 2;
		var _aa  = key_dragging == _k && key_deleting? 0.3 : 1;
		
		draw_sprite_stretched_ext(THEME.prop_gradient, 0, _kdx, _kdy, _kw, _kh, _c, _aa);
		
		if(key_selecting == _k || key_dragging == _k) {
			draw_sprite_stretched_ext(THEME.prop_gradient, 1, _kdx, _kdy, _kw, _kh, _color_get_light(_c) < 0.75? c_white : c_black, _aa);
			draw_sprite_stretched_ext(THEME.prop_gradient, 2, _kdx, _kdy, _kw, _kh, COLORS._main_accent, _aa);
			
		} else {
			draw_sprite_stretched_ext(THEME.prop_gradient, 2, _kdx, _kdy, _kw, _kh, _color_get_light(_c) < 0.75? c_white : c_black, _aa);
		}
			
		if(_hov) hover = _k;
	}
	
	if(key_dragging) {
		if(abs(mouse_mx - key_drag_mx) > 4)
			key_drag_dead = false;
		key_deleting = abs(mouse_my - key_drag_my) > ui(32) && array_length(gradient.keys) > 1;
		
		if(!key_drag_dead && !key_deleting) {
			var newT = clamp(key_drag_sx + (mouse_mx - key_drag_mx) / gr_w, 0, 1);
			setKeyPosition(key_dragging, newT);
		}
		
		if(mouse_release(mb_left)) {
			if(key_deleting) array_remove(gradient.keys, key_dragging);
			else             removeKeyOverlap(key_dragging);
			
			key_dragging = noone;
		}
	}
	
	var _x0 = gr_x - ui(6);
	var _x1 = gr_x + gr_w + ui(12);
	var _y0 = gr_y - ui(6);
	var _y1 = gr_y + gr_h + ui(12);
	
	if(sHOVER && point_in_rectangle(mouse_mx, mouse_my, _x0, _y0, _x1, _y1)) {
		if(mouse_press(mb_left, sFOCUS)) {
			widget_clear();
			
			if(hover) {
				key_selecting = hover;
				if(interactable) {
					key_dragging  = hover;
					key_drag_dead = true;
					key_deleting  = false;
					
					key_drag_sx	  = hover.time;
					key_drag_mx	  = mouse_mx;
					key_drag_my	  = mouse_my;
				}
				
				selector.setColor(hover.value);
				
			} else if(interactable) {
				key_selecting = noone;
				
				var tt = clamp((mouse_mx - gr_x) / gr_w, 0, 1);
				var cc = gradient.eval(tt);
				
				var _newkey = new gradientKey(tt, cc);
				gradient.add(_newkey, true);
				
				key_selecting = _newkey;
				key_dragging  = _newkey;
				key_drag_dead = true;
				key_deleting  = false;
				
				key_drag_sx	  = tt;
				key_drag_mx	  = mouse_mx;
				key_drag_my	  = mouse_my;
				
				selector.setColor(key_dragging.value);
				onApply(gradient);
			}
		}
			
		if(mouse_press(mb_right, interactable && sFOCUS) && hover && array_length(gradient.keys) > 1) {
			array_remove(gradient.keys, hover);
			onApply(gradient);
		}
	}
	
	var op_x = content_x + ui(22);
	var op_y = gr_y + gr_h + ui(12);
	
	var txt = key_selecting? key_selecting.time * 100 : 0;
	sl_position.setFocusHover(sFOCUS, sHOVER);
	sl_position.register();
	sl_position.setFont(f_p2);
	sl_position.draw(op_x, op_y, content_w - ui(44), ui(24), txt, mouse_ui);
#endregion

#region selector
	var col_x = content_x + ui(20);
	var col_y = dialog_y + ui(128);
	
	if(palette_selecting != undefined) selector.palette = palette_selecting;
	selector.draw(col_x, col_y, sFOCUS, sHOVER);
#endregion

#region controls
	var bx = content_x + content_w - ui(36);
	var by = dialog_y + dialog_h - ui(36);
	
	b_apply.register();
	b_apply.setFocusHover(sFOCUS, sHOVER);
	b_apply.draw(bx - ui(18), by - ui(18), ui(36), ui(36), mouse_ui, THEME.button_lime);
	
	bx -= ui(48);
	b_cancel.register();
	b_cancel.setFocusHover(sFOCUS, sHOVER);
	b_cancel.draw(bx - ui(18), by - ui(18), ui(36), ui(36), mouse_ui, THEME.button_hide_fill);
#endregion