/// @description init
event_inherited();

#region data
	dialog_w = ui(240);
	dialog_h = ui(400);
	
	node = noone;
	destroy_on_click_out = true;
	
	anchor = ANCHOR.left | ANCHOR.top;
	
	adding  = false;
	add_txt = "";
	tb_add  = new textBox(TEXTBOX_INPUT.text, function(txt) /*=>*/ { add_txt = txt; newPresetFromNode(txt); adding = false; });
#endregion

#region content
	sc_presets = new scrollPane(dialog_w - ui(padding + padding), dialog_h - ui(title_height + padding), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var _h = 0;
		if(node == noone) return _h;
		
		if(adding) {
			tb_add.setFocusHover(sc_presets.active, sc_presets.hover);
			var _wh = tb_add.draw(0, _y, sc_presets.surface_w, TEXTBOX_HEIGHT, add_txt);
			
			_h += _wh + ui(4);
			_y += _wh + ui(4);
		}
		
		var folder = instanceof(node);
		if(!ds_map_exists(global.PRESETS_MAP, folder)) return 0;
		
		var pres = global.PRESETS_MAP[? folder];
		var amo  = array_length(pres);
		var hh   = line_get_height() + ui(8);
		    _h  += amo * (hh + ui(4)) + ui(32);
		
		for( var i = 0; i < amo; i++ ) {
			var preset = pres[i];
			var _yy = _y + (hh + ui(4)) * i;
			
			if(sHOVER && sc_presets.hover && point_in_rectangle(_m[0], _m[1], 0, _yy, sc_presets.w, _yy + hh)) {
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, _yy, sc_presets.w - ui(12), hh, COLORS._main_icon, 0.85);
				
				if(mouse_click(mb_left, sFOCUS)) {
					node.deserialize(preset.content, true, true);
					instance_destroy();
				}
				
				if(mouse_click(mb_right, sFOCUS)) {
					var dia = menuCall("preset_window_menu",,, [ 
						menuItem(__txt("Delete"), function() { 
							file_delete(o_dialog_menubox.path);
							__initPresets();
						}), 
					],, preset);
					dia.path = preset.path;
				}
			}
			
			draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
			draw_text_add(ui(8), _yy + hh / 2, preset.name);
		}
		
		return _h;
	});
#endregion

#region new preset
	function newPresetFromNode(name) {
		if(node == noone) return;
		var dir = $"{DIRECTORY}Presets/{instanceof(node)}/";
		directory_verify(dir);
		
		var pth = dir + name + ".json";
		var map = node.serialize(true, true);
		json_save_struct(pth, map);
		__initPresets();
	}
#endregion