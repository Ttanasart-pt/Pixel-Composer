/// @description init
if !ready exit;

#region dropper
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
	
	draw_sprite_stretched(THEME.dialog_bg, 0, presets_x, dialog_y, presets_w, dialog_h);
	if(sFOCUS) draw_sprite_stretched_ext(THEME.dialog_active, 0, presets_x, dialog_y, presets_w, dialog_h, COLORS._main_accent, 1);
	
	draw_sprite_stretched(THEME.dialog_bg, 0, content_x, dialog_y, content_w, dialog_h);
	if(sFOCUS) draw_sprite_stretched_ext(THEME.dialog_active, 0, content_x, dialog_y, content_w, dialog_h, COLORS._main_accent, 1);
	
	draw_sprite_stretched(THEME.dialog_bg, 0, palette_x, dialog_y, presets_w, dialog_h);
	if(sFOCUS) draw_sprite_stretched_ext(THEME.dialog_active, 0, palette_x, dialog_y, presets_w, dialog_h, COLORS._main_accent, 1);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text_title);
	draw_text(presets_x + ui(24), dialog_y + ui(16), get_text("presets", "Presets"));
	draw_text(content_x + ui(24), dialog_y + ui(16), name);
	draw_text(palette_x + ui(24), dialog_y + ui(16), get_text("palette", "Palettes"));
#endregion

#region presets
	draw_sprite_stretched(THEME.ui_panel_bg, 0, presets_x + ui(16), dialog_y + ui(44), ui(240 - 32), dialog_h - ui(60));
	
	sp_presets.active = sFOCUS;
	sp_presets.draw(presets_x + ui(16 + 8), dialog_y + ui(44));
	
	var bx = presets_x + presets_w - ui(44);
	var by = dialog_y + ui(12);
	
	var _b = buttonInstant(THEME.button_hide, bx, by, ui(28), ui(28), mouse_ui, sFOCUS, sHOVER, get_text("add_preset", "Add to preset"));
	
	if(_b == 2) {
		var dia = dialogCall(o_dialog_file_name, mouse_mx + ui(8), mouse_my + ui(8));
		dia.onModify = function (txt) {
			var gradStr = "";
			for(var i = 0; i < array_length(gradient); i++) {
				var gr = gradient[i];
				var cc = gr.value;
				var tt = gr.time;
				
				gradStr += string(cc) + "," + string(tt) + "\n";
			}
			
			var file = file_text_open_write(txt + ".txt");
			file_text_write_string(file, gradStr);
			file_text_close(file);
			presetCollect();
		};
		dia.path = DIRECTORY + "Gradients/"
	}
	draw_sprite_ui_uniform(THEME.add, 0, bx + ui(14), by + ui(14), 1, COLORS._main_icon);
	bx -= ui(32);
	
	if(buttonInstant(THEME.button_hide, bx, by, ui(28), ui(28), mouse_ui, sFOCUS, sHOVER, get_text("refresh", "Refresh"), THEME.refresh) == 2)
		presetCollect();
	bx -= ui(32);
	
	if(buttonInstant(THEME.button_hide, bx, by, ui(28), ui(28), mouse_ui, sFOCUS, sHOVER, "Open gradient folder", THEME.folder) == 2) {
		var _realpath = environment_get_variable("LOCALAPPDATA") + "\\Pixels_Composer\\Gradients";
		var _windir   = environment_get_variable("WINDIR") + "\\explorer.exe";
		execute_shell(_windir, _realpath);
	}
	bx -= ui(32);
#endregion

#region palette
	draw_sprite_stretched(THEME.ui_panel_bg, 0, palette_x + ui(16), dialog_y + ui(44), ui(240 - 32), dialog_h - ui(60));
	
	sp_palettes.active = sFOCUS;
	sp_palettes.draw(palette_x + ui(16 + 8), dialog_y + ui(44));
#endregion

#region gradient
	var gr_x = content_x + ui(22);
	var gr_y = dialog_y + ui(54);
	var gr_w = content_w - ui(44);
	var gr_h = ui(20);
	
	#region tools
		var bx = content_x + content_w - ui(50);
		var by = dialog_y + ui(16);
		
		if(buttonInstant(THEME.button_hide, bx, by, ui(28), ui(28), mouse_ui, sFOCUS, sHOVER, get_text("gradient_editor_key_blend", "Key blending"), THEME.grad_blend) == 2) {
			menuCall( bx + ui(32), by, [ 
				menuItem(get_text("gradient_editor_blend_RGB",  "RGB blend"),  function() { grad_data[| 0] = 0; }), 
				menuItem(get_text("gradient_editor_blend_HSV",  "HSV blend"),  function() { grad_data[| 0] = 2; }), 
				menuItem(get_text("gradient_editor_blend_hard", "Hard blend"), function() { grad_data[| 0] = 1; }), 
			]);
		}
		bx -= ui(32);
	#endregion
	
	draw_sprite_stretched(THEME.textbox, 3, gr_x - ui(6), gr_y - ui(6), gr_w + ui(12), gr_h + ui(12));
	draw_sprite_stretched(THEME.textbox, 0, gr_x - ui(6), gr_y - ui(6), gr_w + ui(12), gr_h + ui(12));
	draw_gradient(gr_x, gr_y, gr_w, gr_h, gradient, grad_data[| 0]);
	
	var hover = noone;
	for(var i = 0; i < array_length(gradient); i++) {
		var _k  = gradient[i];
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
				key_dragging  = hover;
				key_drag_sx	  = hover.time;
				key_drag_mx	  = mouse_mx;
				key_drag_dead = true;
				
				selector.setColor(key_dragging.value);
			} else {
				key_selecting = noone;
				
				var tt = clamp((mouse_mx - gr_x) / gr_w, 0, 1);
				var cc = gradient_eval(gradient, tt);
				var _newkey = new gradientKey(tt, cc);
				gradient_add(gradient, _newkey, true);
					
				key_selecting  = _newkey;
				key_dragging   = _newkey;
				key_drag_sx	  = tt;
				key_drag_mx	  = mouse_mx;
				key_drag_dead = false;
				
				selector.setColor(key_dragging.value);
			}
		}
			
		if(mouse_press(mb_right, sFOCUS) && hover && array_length(gradient) > 1)
			array_remove(gradient, hover);
	}
	
	var op_x = content_x + ui(20);
	var op_y = gr_y + gr_h + ui(12);
	
	draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_sub);
	draw_text(op_x, op_y + TEXTBOX_HEIGHT / 2, get_text("position", "Position"))
	
	var txt = key_selecting? key_selecting.time * 100 : 0;
	sl_position.active = sFOCUS;
	sl_position.hover  = sHOVER;
	sl_position.register();
	sl_position.draw(op_x + ui(100), op_y, ui(content_w - 140), TEXTBOX_HEIGHT, txt, mouse_ui);
#endregion

#region selector
	var col_x = content_x + ui(20);
	var col_y = dialog_y + ui(136);
	
	selector.draw(col_x, col_y, sFOCUS, sHOVER);
#endregion

#region controls
	var bx = content_x + content_w - ui(36);
	var by = dialog_y + dialog_h - ui(36);
	
	b_apply.register();
	b_apply.hover  = sHOVER;
	b_apply.active = sFOCUS;
	b_apply.draw(bx - ui(18), by - ui(18), ui(36), ui(36), mouse_ui, THEME.button_lime);
	
	bx -= ui(48);
	b_cancel.register();
	b_cancel.hover  = sHOVER;
	b_cancel.active = sFOCUS;
	b_cancel.draw(bx - ui(18), by - ui(18), ui(36), ui(36), mouse_ui, THEME.button_hide);
#endregion