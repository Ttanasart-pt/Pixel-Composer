/// @description init
if !ready exit;

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
	
	draw_sprite_stretched(THEME.dialog_bg, 0, presets_x - p, dialog_y - p, presets_w + p2, dialog_h + p2);
	if(sFOCUS) draw_sprite_stretched_ext(THEME.dialog_active, 0, presets_x - p, dialog_y - p, presets_w + p2, dialog_h + p2, COLORS._main_accent, 1);
	
	draw_sprite_stretched(THEME.dialog_bg, 0, content_x - p, dialog_y - p, content_w + p2, dialog_h + p2);
	if(sFOCUS) draw_sprite_stretched_ext(THEME.dialog_active, 0, content_x - p, dialog_y - p, content_w + p2, dialog_h + p2, COLORS._main_accent, 1);
	
	draw_sprite_stretched(THEME.dialog_bg, 0, palette_x - p, dialog_y - p, presets_w + p2, dialog_h + p2);
	if(sFOCUS) draw_sprite_stretched_ext(THEME.dialog_active, 0, palette_x - p, dialog_y - p, presets_w + p2, dialog_h + p2, COLORS._main_accent, 1);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
	draw_text(presets_x + ui(24), dialog_y + ui(16), __txt("Presets"));
	draw_text(content_x + (!interactable * ui(32)) + ui(24), dialog_y + ui(16), name);
	if(!interactable)
		draw_sprite_ui(THEME.lock, 0, content_x + ui(24 + 12), dialog_y + ui(16 + 12),,,, COLORS._main_icon);
	draw_text(palette_x + ui(24), dialog_y + ui(16), __txt("Palettes"));
#endregion

#region presets
	draw_sprite_stretched(THEME.ui_panel_bg, 1, presets_x + ui(16), dialog_y + ui(44), ui(240 - 32), dialog_h - ui(60));
	
	sp_presets.setFocusHover(sFOCUS, sHOVER);
	sp_presets.draw(presets_x + ui(16 + 8), dialog_y + ui(44));
	
	var bx = presets_x + presets_w - ui(44);
	var by = dialog_y + ui(12);
	var bs = ui(28);
	
	if(buttonInstant(THEME.button_hide, bx, by, bs, bs, mouse_ui, sFOCUS, sHOVER, __txtx("add_preset", "Add to preset"), THEME.add_20) == 2) {
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
	bx -= ui(32);
	
	if(buttonInstant(THEME.button_hide, bx, by, bs, bs, mouse_ui, sFOCUS, sHOVER, __txt("Refresh"), THEME.refresh_20) == 2)
		__initGradient();
	bx -= ui(32);
	
	if(buttonInstant(THEME.button_hide, bx, by, bs, bs, mouse_ui, sFOCUS, sHOVER, __txtx("graident_editor_open_folder", "Open gradient folder"), THEME.path_open_20) == 2) {
		var _realpath = DIRECTORY + "Gradients";
		shellOpenExplorer(_realpath)
	}
	draw_sprite_ui_uniform(THEME.path_open_20, 1, bx + bs / 2, by + bs / 2, 1, c_white);
	bx -= ui(32);
#endregion

#region palette
	draw_sprite_stretched(THEME.ui_panel_bg, 1, palette_x + ui(16), dialog_y + ui(44), ui(240 - 32), dialog_h - ui(60));
	
	sp_palettes.setFocusHover(sFOCUS, sHOVER);
	sp_palettes.draw(palette_x + ui(16 + 8), dialog_y + ui(44));
	
	var bx = palette_x + palette_w - ui(44);
	var by = dialog_y + ui(12);
	
	if(buttonInstant(THEME.button_hide, bx, by, ui(28), ui(28), mouse_ui, sFOCUS, sHOVER, __txt("Show on Selector"), THEME.display_palette, NODE_COLOR_SHOW_PALETTE, c_white) == 2)
		NODE_COLOR_SHOW_PALETTE = !NODE_COLOR_SHOW_PALETTE;
	bx -= ui(32);
#endregion

#region gradient
	var gr_x = content_x + ui(22);
	var gr_y = dialog_y + ui(54);
	var gr_w = content_w - ui(44);
	var gr_h = ui(20);
	
	#region tools
		var bx = content_x + content_w - ui(50);
		var by = dialog_y + ui(16);
		
		if(buttonInstant(THEME.button_hide, bx, by, ui(28), ui(28), mouse_ui, interactable && sFOCUS, sHOVER, __txtx("gradient_editor_key_blend", "Key blending"), THEME.grad_blend) == 2) {
			menuCall("gradient_window_blend_menu", bx + ui(32), by, [ 
				menuItem(__txtx("gradient_editor_blend_RGB",  "RGB blend"),  function() { gradient.type = 0; onApply(gradient); }), 
				menuItem(__txtx("gradient_editor_blend_HSV",  "HSV blend"),  function() { gradient.type = 2; onApply(gradient); }), 
				menuItem(__txtx("gradient_editor_blend_hard", "Hard blend"), function() { gradient.type = 1; onApply(gradient); }), 
			],, gradient);
		}
		bx -= ui(32);
		
		if(buttonInstant(THEME.button_hide, bx, by, ui(28), ui(28), mouse_ui, interactable && sFOCUS, sHOVER, __txtx("gradient_editor_reverse", "Reverse"), THEME.reverse) == 2) {
			for( var i = 0, n = array_length(gradient.keys); i < n; i++ )
				gradient.keys[i].time = 1 - gradient.keys[i].time;
			gradient.keys = array_reverse(gradient.keys);
			onApply(gradient);
		}
		bx -= ui(32);
	#endregion
	
	draw_sprite_stretched(THEME.textbox, 3, gr_x - ui(6), gr_y - ui(6), gr_w + ui(12), gr_h + ui(12));
	draw_sprite_stretched(THEME.textbox, 0, gr_x - ui(6), gr_y - ui(6), gr_w + ui(12), gr_h + ui(12));
	gradient.draw(gr_x, gr_y, gr_w, gr_h);
	
	var hover = noone;
	for(var i = 0; i < array_length(gradient.keys); i++) {
		var _k  = gradient.keys[i];
		var _c  = _k.value;
		var _kx = gr_x + _k.time * gr_w; 
		var _in = _k == key_selecting? 1 : 0;
		
		draw_sprite_ui_uniform(THEME.prop_gradient, _in, _kx, gr_y + gr_h / 2, 1, _c);
		
		if(sHOVER && point_in_rectangle(mouse_mx, mouse_my, _kx - ui(6), gr_y, _kx + ui(6), gr_y + gr_h)) {
			draw_sprite_ui_uniform(THEME.prop_gradient, _in, _kx, gr_y + gr_h / 2, 1.2, _c);
			hover = _k;
		}
	}
	
	if(key_dragging) {
		if(abs(mouse_mx - key_drag_mx) > 4)
			key_drag_dead = false;
		
		if(!key_drag_dead) {
			var newT = key_drag_sx + (mouse_mx - key_drag_mx) / gr_w;
			newT = clamp(newT, 0, 1);
			setKeyPosition(key_dragging, newT);
		}
		
		if(mouse_release(mb_left)) {
			removeKeyOverlap(key_dragging);
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
					key_drag_sx	  = hover.time;
					key_drag_mx	  = mouse_mx;
					key_drag_dead = true;
				}
				
				selector.setColor(hover.value);
			} else if(interactable) {
				key_selecting = noone;
				
				var tt = clamp((mouse_mx - gr_x) / gr_w, 0, 1);
				var cc = gradient.eval(tt);
				var _newkey = new gradientKey(tt, cc);
				gradient.add(_newkey, true);
					
				key_selecting  = _newkey;
				key_dragging   = _newkey;
				key_drag_sx	  = tt;
				key_drag_mx	  = mouse_mx;
				key_drag_dead = false;
				
				selector.setColor(key_dragging.value);
			}
		}
			
		if(mouse_press(mb_right, interactable && sFOCUS) && hover && array_length(gradient.keys) > 1)
			array_remove(gradient.keys, hover);
	}
	
	var op_x = content_x + ui(20);
	var op_y = gr_y + gr_h + ui(12);
	
	draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_sub);
	draw_text(op_x, op_y + TEXTBOX_HEIGHT / 2, __txt("Position"))
	
	var txt = key_selecting? key_selecting.time * 100 : 0;
	sl_position.setFocusHover(sFOCUS, sHOVER);
	sl_position.register();
	sl_position.draw(op_x + ui(100), op_y, ui(content_w - 140), TEXTBOX_HEIGHT, txt, mouse_ui);
#endregion

#region selector
	var col_x = content_x + ui(20);
	var col_y = dialog_y + ui(136);
	
	if(palette_selecting > -1)
		selector.palette = PALETTES[palette_selecting].palette;
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
	b_cancel.draw(bx - ui(18), by - ui(18), ui(36), ui(36), mouse_ui, THEME.button_hide);
#endregion