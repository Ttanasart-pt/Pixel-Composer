globalvar SPRITE_PATH_MAP;
SPRITE_PATH_MAP = {};

function sprite_delete_safe(spr) { if(sprite_exists(spr)) sprite_delete(spr); }

#macro __sprite_add sprite_add
#macro sprite_add sprite_add_os
function sprite_add_os(path, imagenumb = 1, removeback = false, smooth = false, xorig = 0, yorig = 0) { 
	return __sprite_add(filename_os(path), imagenumb, removeback, smooth, xorig, yorig); 
}

function sprite_add_map(path, imagenumb = 1, removeback = false, smooth = false, xorig = 0, yorig = 0) {
	if(!file_exists_empty(path)) return noone;
	var _path = sprite_path_check_format(filename_os(path));
	var _extx = string_lower(filename_ext(_path));
	var _sprs = undefined;
	
	switch(_extx) {
		case ".bmp": _sprs = sprite_create_from_file(_path, removeback, smooth, xorig, yorig); break;
		default:     _sprs = __sprite_add(_path, imagenumb, removeback, smooth, xorig, yorig); break;
	}
	
	SPRITE_PATH_MAP[$ path] = _sprs;
	return _sprs;
}

function sprite_add_center(path) {
	if(!file_exists_empty(path)) return noone;
	
	var _s = sprite_add(path, 0, 0, 0, 0, 0);
	
	var _sw = sprite_get_width(_s);
	var _sh = sprite_get_height(_s);
	sprite_set_offset(_s, _sw / 2, _sh / 2);
	
	return _s;
}

function sprite_set_center(spr) { sprite_set_offset(spr, sprite_get_width(spr) / 2, sprite_get_height(spr) / 2); }

function sprite_get_splices(path) {
	var _temp = sprite_add(path, 0, false, false, 0, 0);
	var ww    = sprite_get_width(_temp);
	var hh    = sprite_get_height(_temp);
	var amo   = safe_mod(ww, hh) == 0? ww / hh : 1;
	sprite_delete(_temp);
	
	return amo;
}

function sprite_path_check_format(_path, noti = true) {
	static path_convert = filepath_resolve(PREFERENCES.ImageMagick_path) + "convert.exe";
	static path_magick  = filepath_resolve(PREFERENCES.ImageMagick_path) + "magick.exe";
	
	var _extx = string_lower(filename_ext(_path));
	var _name = filename_name_only(_path);
	var proxy_path  = $"{TEMPDIR}{_name}_{seed_random(6)}.png";
	
	switch(_extx) {
		case ".png":
			var _data = read_png_header(_path, noti);
			if(_data == noone || _data.depth <= 8) return _path;
			
			if(noti) noti_warning($"{_data.depth} bits image is not supported. Proxy will be used.");
			
			var shell_cmd = $"convert \"{_path}\" -depth 8 \"{proxy_path}\"";
			shell_execute(path_magick, shell_cmd, self);
			return proxy_path;
			
		case ".tga": 
			if(noti) noti_warning($"Used proxy for {_extx} file.");
			shell_execute(path_convert, $"\"{_path}\" \"{proxy_path}\"");
			return proxy_path;
			
		case ".webp": 
			if(noti) noti_warning($"Used proxy for {_extx} file.");
			shell_execute(path_convert, $"\"{_path}\" \"{proxy_path}\"");
			return proxy_path;
	}
	
	return _path;
}

#region ================================= SERIALIZE ==================================

	function   sprite_array_serialize(arr) { return json_stringify(__sprite_array_serialize(arr)); }
	function __sprite_array_serialize(arr) {
		if(!is_array(arr)) {
			if(!sprite_exists(arr)) return arr;
			
			var ww   = sprite_get_width(arr);
			var hh   = sprite_get_height(arr);
			var _srf = surface_create(ww, hh);
			surface_set_target(_srf); DRAW_CLEAR draw_sprite(arr, 0, 0, 0); surface_reset_target();
			
			var buff = buffer_create(ww * hh * 4, buffer_fixed, 1);
			buffer_get_surface(buff, _srf, 0);
			var comp = buffer_compress(buff, 0, buffer_get_size(buff));
			var enc  = buffer_base64_encode(comp, 0, buffer_get_size(comp));
			
			surface_free(_srf);
			buffer_delete(buff);
			
			return { width: ww, height: hh, buffer: enc };
		}
	
		var _arr = array_create(array_length(arr));
		for( var i = 0, n = array_length(arr); i < n; i++ ) 
			_arr[i] = __sprite_array_serialize(arr[i]);
	
		return _arr;
	}

	function   sprite_array_deserialize(dat) { return __sprite_array_deserialize(json_try_parse(dat, 0)); }
	function __sprite_array_deserialize(arr) {
		if(!is_array(arr)) {
			if(!is_struct(arr) || !struct_has(arr, "buffer")) return noone;
			
			var buff  = buffer_base64_decode(arr.buffer);
			    buff  = buffer_decompress(buff);
			var _surf = surface_create_from_buffer(arr.width, arr.height, buff);
			var _spr  = sprite_create_from_surface(_surf, 0, 0, arr.width, arr.height, false, false, 0, 0);
			surface_free_safe(_surf);
			
			return _spr;
		}
	
		var _arr = array_create(array_length(arr));
		for( var i = 0, n = array_length(arr); i < n; i++ ) 
			_arr[i] = __sprite_array_deserialize(arr[i]);
	
		return _arr;
	}

#endregion