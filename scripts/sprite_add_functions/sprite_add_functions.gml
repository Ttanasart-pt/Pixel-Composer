globalvar SPRITE_PATH_MAP;
SPRITE_PATH_MAP = {};

function sprite_add_map(path) {
	var _real_path = sprite_path_check_depth(path);
	var _s = sprite_add(_real_path, 1, 0, 0, 0, 0);
	SPRITE_PATH_MAP[$ path] = _s;
	return _s;
}

function sprite_add_center(path) {
	if(!file_exists_empty(path)) return noone;
	
	var _s = sprite_add(path, 0, 0, 0, 0, 0);
	
	var _sw = sprite_get_width(_s);
	var _sh = sprite_get_height(_s);
	sprite_set_offset(_s, _sw / 2, _sh / 2);
	
	return _s;
}

function sprite_path_check_depth(path, noti = true) {
	if(filename_ext(path) != ".png") return path;
	
	var _data = read_png_header(path, noti);
	if(_data == noone) return path;
	if(_data.depth == 8) return path;
	
	if(noti) noti_warning($"{_data.depth} bits image is not supported. Proxy will be used.");
	
	var path_magick = filepath_resolve(PREFERENCES.ImageMagick_path) + "magick.exe";
	var proxy_path  = $"{TEMPDIR}{filename_name_only(path)}_{seed_random(6)}.png";
	var shell_cmd   = $"convert \"{path}\" -depth 8 \"{proxy_path}\"";
	shell_execute(path_magick, shell_cmd, self);
	
	return proxy_path;
}