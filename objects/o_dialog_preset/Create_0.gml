/// @description init
event_inherited();

#region data
	dialog_w = ui(240);
	dialog_h = ui(400);
	
	node = noone;
	destroy_on_click_out = true;
	
	padding = ui(24);
	anchor = ANCHOR.left | ANCHOR.top;
#endregion

#region content
	sc_presets = new scrollPane(dialog_w - ui(padding + padding), dialog_h - ui(64 + padding), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		if(node == noone) return 0;
		
		var folder = instanceof(node);
		if(!ds_map_exists(global.PRESETS_MAP, folder)) return 0;
		
		var pres = global.PRESETS_MAP[? folder];
		var amo = array_length(pres);
		var hh  = line_height() + ui(8);
		var _h = amo * hh;
		
		for( var i = 0; i < amo; i++ ) {
			var preset = pres[i];
			var _yy = _y + hh * i;
			
			if(sHOVER && sc_presets.hover && point_in_rectangle(_m[0], _m[1], 0, _yy, sc_presets.w, _yy + hh)) {
				draw_sprite_stretched(THEME.node_bg, 0, 0, _yy, sc_presets.w - ui(12), hh);
				if(mouse_click(mb_left, sFOCUS)) {
					node.deserialize(preset.content, true, true);
					instance_destroy();
				}
				
				if(mouse_click(mb_right, sFOCUS)) {
					var dia = dialogCall(o_dialog_menubox, mouse_mx + ui(8), mouse_my + ui(8));
					dia.path = preset.path;
					dia.setMenu([ 
						[ "Delete", function() { 
							file_delete(o_dialog_menubox.path);
							__initPresets();
						} ], 
					]);
				}
			}
			
			draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
			draw_text(ui(8), _yy + hh / 2, preset.name);
			
			//draw_set_color(COLORS._main_text_sub);
			//draw_line(ui(8), _yy + hh, sc_presets.w - ui(16), _yy + hh);
		}
		
		return _h;
	})
#endregion

#region new preset
	function newPresetFromNode(name) {
		if(node == noone) return;
		var dir = DIRECTORY + "Presets/" + instanceof(node) + "/";
		if(!directory_exists(dir))
			directory_create(dir);
		
		var pth = dir + name + ".json";
		var map = node.serialize(true, true);
		json_save(pth, map);
		__initPresets();
	}
#endregion