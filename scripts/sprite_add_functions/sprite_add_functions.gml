globalvar SPRITE_PATH_MAP;
SPRITE_PATH_MAP = {};

#macro __sprite_add sprite_add
#macro sprite_add sprite_add_os
function sprite_add_os(path, imagenumb, removeback, smooth, xorig, yorig) { 
	return __sprite_add(filename_os(path), imagenumb, removeback, smooth, xorig, yorig); 
}

function sprite_add_map(path, imagenumb = 1, removeback = false, smooth = false, xorig = 0, yorig = 0) {
	var _path = sprite_path_check_depth(filename_os(path));
	var _sprs = sprite_add(_path, imagenumb, removeback, smooth, xorig, yorig);
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

function sprite_path_check_depth(path, noti = true) {
	if(filename_ext(path) != ".png") return path;
	
	var _data = read_png_header(path, noti);
	if(_data == noone)   return path;
	if(_data.depth <= 8) return path;
	
	if(noti) noti_warning($"{_data.depth} bits image is not supported. Proxy will be used.");
	
	var path_magick = filepath_resolve(PREFERENCES.ImageMagick_path) + "magick.exe";
	var proxy_path  = $"{TEMPDIR}{filename_name_only(path)}_{seed_random(6)}.png";
	var shell_cmd   = $"convert \"{path}\" -depth 8 \"{proxy_path}\"";
	shell_execute(path_magick, shell_cmd, self);
	
	return proxy_path;
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