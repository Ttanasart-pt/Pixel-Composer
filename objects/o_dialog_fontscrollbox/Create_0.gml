/// @description init
event_inherited();

#region 
	destroy_on_click_out = true;
	
	dialog_w  = 560;
	max_h     = 640;
	draggable = false;
	selecting = -1;
	anchor    = ANCHOR.top | ANCHOR.left;
	scrollbox = noone;
	
	curr_data = FONT_INTERNAL;
	
	sc_content = new scrollPane(0, 0, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var hght = line_get_height(f_p0, 8);
		var data = curr_data;
		var _h   = array_length(data) * hght;
		var _dw  = sc_content.surface_w;
		var _dh  = sc_content.surface_h;
		
		sc_content.hover_content = true;
		
		for( var i = 0, n = array_length(data); i < n; i++ ) {
			var _ly = _y + i * hght;	
			var fullpath = data[i];
			
			if(sc_content.hover && MOUSE_MOVED && point_in_rectangle(_m[0], _m[1], 0, _ly + 1, _dw, _ly + hght - 1))
				selecting = i;
			
			if(selecting == i) {
				draw_sprite_stretched_ext(THEME.textbox, 3, 0, _ly, _dw, hght, COLORS.dialog_menubox_highlight, 1);
				
				if(sFOCUS && (mouse_press(mb_left) || KEYBOARD_ENTER)) {
					scrollbox.onModify(fullpath);
					instance_destroy();
				}
			}
					
			if(_ly + hght < 0 || _ly > _dh) continue;
					
			draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
			
			var _scis = gpu_get_scissor();
			gpu_set_scissor(ui(8), _ly, _dw, hght);
			draw_text_add(ui(8), _ly + hght / 2, filename_name_only(data[i]));
			gpu_set_scissor(_scis);
			
			if(!ds_map_exists(FONT_SPRITES, fullpath)) loadFontSprite(fullpath);
			
			var spr = FONT_SPRITES[? fullpath];
			if(!sprite_exists(spr)) continue;
			
			var sw  = sprite_get_width(spr);
			var sh  = sprite_get_height(spr);
			var ss  = (hght - ui(8)) / sh;
			
			sw *= ss;
			sh *= ss;
			
			draw_sprite_ext(spr, 0, _dw - ui(8) - sw, _ly + hght / 2 - sh / 2, ss, ss, 0, c_white, 1);
		}
		
		if(sFOCUS) {
			if(KEYBOARD_PRESSED == vk_up) {
				selecting--;
				if(selecting < 0) selecting = array_length(data) - 1;
			}
			
			if(KEYBOARD_PRESSED == vk_down)
				selecting = safe_mod(selecting + 1, array_length(data));
			
			if(keyboard_check_pressed(vk_escape))
				instance_destroy();
		}
		
		return _h;
	});
#endregion

#region search
	search_string	= "";
	KEYBOARD_RESET
	tb_search = new textBox(TEXTBOX_INPUT.text, function(s) /*=>*/ { search_string = string(s); filterSearch(); })
					.setFont(f_p2)
					.setAutoUpdate()
					.setEmpty()
					.setAlign(fa_left);
	
	WIDGET_CURRENT  = tb_search;
	
	function filterSearch() {
		curr_data = FONT_INTERNAL;
		if(search_string == "") return;
		
		curr_data = [];
		for( var i = 0, n = array_length(FONT_INTERNAL); i < n; i++ ) {
			var  val = FONT_INTERNAL[i];
			var _txt = filename_name_only(val);
			
			if(string_pos(string_lower(search_string), string_lower(_txt)) > 0)
				array_push(curr_data, val);
		}
		
	}
#endregion
