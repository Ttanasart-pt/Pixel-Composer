globalvar FONT_INTERNAL, FONT_SPRITES;
FONT_SPRITES = ds_map_create();

function loadFontSprite(path) {
	if(ds_map_exists(FONT_SPRITES, path)) return;
	
	var f = _font_add(path, 32);
	if(!font_exists(f)) return;
	
	draw_set_text(f, fa_left, fa_top, c_white);
	var name = "ABCabc123";
	var ww   = max(1, string_width(name));
	var hh   = max(1, string_height(name));
	
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
	readFontFolder(DIRECTORY + "Fonts/");
	
	for (var i = 0, n = array_length(PREFERENCES.path_fonts); i < n; i++)
		readFontFolder(string_trim_end(PREFERENCES.path_fonts[i], ["/"]) + "/");
}

function readFontFolder(dirPath) {
	var root   = dirPath + "*";
	var filter = [ ".ttf", ".otf" ];
	var fil    = file_find_first(root, -1);
	var ful, ext;
	
	while(fil != "") {
		ful = dirPath + fil;
		fil = file_find_next();
		ext = filename_ext(ful);
		
		if(!array_exists(filter, string_lower(ext))) continue;
		
		array_push(FONT_INTERNAL, ful);
		loadFontSprite(ful);
	}
	
	file_find_close();
}