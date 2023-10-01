globalvar FONT_INTERNAL, FONT_SPRITES;
FONT_SPRITES = ds_map_create();

#region font refresh
	function loadFontSprite(path) {
		if(ds_map_exists(FONT_SPRITES, path)) return;
		
		var f = _font_add(path, 32);
		draw_set_text(f, fa_left, fa_top, c_white);
		var name = "ABCabc123";
		var ww = string_width(name);
		var hh = string_height(name);
		
		var s = surface_create(ww, hh);
		surface_set_target(s);
		DRAW_CLEAR
		draw_text(0, 0, name);
		surface_reset_target();
		
		var spr = sprite_create_from_surface(s, 0, 0, ww, hh, false, false, 0, 0);
		surface_free(s);
		font_delete(f);
		
		FONT_SPRITES[? path] = spr;
	}
	
	function refreshFontFolder() {
		FONT_INTERNAL = [];
		var root = DIRECTORY + "Fonts/*";
		var f = file_find_first(root, -1);
		var filter = [ ".ttf", ".otf" ];
		
		while(f != "") {
			var fullname = DIRECTORY + "Fonts/" + f;
			var ext = filename_ext(fullname);
			if(array_exists(filter, string_lower(ext))) {
				array_push(FONT_INTERNAL, f);
				loadFontSprite(fullname);
			}
			f = file_find_next();
		}
		
		file_find_close();
	}
#endregion