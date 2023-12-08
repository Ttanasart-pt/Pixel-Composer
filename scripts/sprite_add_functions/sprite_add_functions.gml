function sprite_add_center(path) {
	if(!file_exists_empty(path)) return noone;
	
	var _s = sprite_add(path, 0, 0, 0, 0, 0);
	
	var _sw = sprite_get_width(_s);
	var _sh = sprite_get_height(_s);
	sprite_set_offset(_s, _sw / 2, _sh / 2);
	
	return _s;
}