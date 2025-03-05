enum GRADIENT_INTER {
	smooth,
	none,
	hue,
	oklab,
	srgb
}

global.gradient_sort_list = ds_priority_create();

function gradientKey(time, value) constructor {
	self.time  = time;
	self.value = value;
	
	_hover = 0;
	
	static clone     = function() { return new gradientKey(time, value); }
	static serialize = function() { return { time, value }; }
}

function gradientObject(color = c_black) constructor {
	static GRADIENT_LIMIT = 128;
	
	if(is_array(color)) keys = [ new gradientKey(0, cola(color[0])), new gradientKey(1, cola(color[1])) ];
	else				keys = [ new gradientKey(0, cola(color)) ];
	type  = GRADIENT_INTER.smooth;
	surf  = noone;
	
	cacheRes  = 128;
	caches    = array_create(cacheRes);
	keyLength = 0;
	
	static refresh = function() { 
		
		ds_priority_clear(global.gradient_sort_list);
		for (var i = 0, n = array_length(keys); i < n; i++) 
			ds_priority_add(global.gradient_sort_list, keys[i], keys[i].time);
		for (var i = 0, n = array_length(keys); i < n; i++) 
			keys[i] = ds_priority_delete_min(global.gradient_sort_list);
			
		cache();
	}
	
	static clone = function() {
		var g = new gradientObject();
		for( var i = 0, n = array_length(keys); i < n; i++ )
			g.keys[i] = keys[i].clone();
		
		g.type      = type;
		
		return g;
	}
	
	static add = function(_addkey, _deleteDup = true) {
		if(array_length(keys) > GRADIENT_LIMIT) return;
		if(array_length(keys) == 0) {
			array_push(keys, _addkey);
			return;
		}
		
		for(var i = 0; i < array_length(keys); i++) {
			var _key = keys[i];
		
			if(_key.time == _addkey.time) {
				if(_deleteDup)
					_key.value = _addkey.value;
				return;
			} else if(_key.time > _addkey.time) {
				array_insert(keys, i, _addkey);
				return;
			}
		}
		
		array_push(keys, _addkey);
	}
	
	static eval = function(position) {
		var _len = array_length(keys);
		if(_len == 0) return c_black;
		if(_len == 1) return keys[0].value;
		
		if(position <= keys[0].time)        return keys[0].value;
		if(position >= keys[_len - 1].time) return keys[_len - 1].value;
		
		for(var i = 1; i < _len; i++) {
			var _pkey = keys[i - 1];
			var _key  = keys[i];
			
			if(_key.time <  position) continue;
			if(_key.time == position) return _key.value;
			
			var rat = (position - _pkey.time) / (_key.time - _pkey.time);
			
			switch(type) {
				case GRADIENT_INTER.smooth : return merge_color_rgba (_pkey.value, _key.value, rat);
				case GRADIENT_INTER.srgb   : return merge_color_srgb (_pkey.value, _key.value, rat);
				case GRADIENT_INTER.hue    : return merge_color_hsva (_pkey.value, _key.value, rat);
				case GRADIENT_INTER.oklab  : return merge_color_oklab(_pkey.value, _key.value, rat);
				case GRADIENT_INTER.none   : return _pkey.value;
			}
		}
	
		return keys[_len - 1].value; //after last color
	}
	
	static evalFast = function(position) {
		INLINE
		var _len = array_length(keys);
		if(position <= keys[0].time)        return keys[0].value;
		if(position >= keys[_len - 1].time) return keys[_len - 1].value;
		
		var _ind = round(position * cacheRes);
		return caches[_ind];
	}
	
	static draw = function(_x, _y, _w, _h, _a = 1) {
		var uniform_grad_blend	= shader_get_uniform(sh_gradient_display, "gradient_blend");
		var uniform_grad		= shader_get_uniform(sh_gradient_display, "gradient_color");
		var uniform_grad_time	= shader_get_uniform(sh_gradient_display, "gradient_time");
		var uniform_grad_key	= shader_get_uniform(sh_gradient_display, "gradient_keys");
	
		var _grad_color = [];
		var _grad_time  = [];
		
		var len = min(128, array_length(keys));
		var aa  = false;
		
		for(var i = 0; i < len; i++) {
			var _val = keys[i].value;
			if(_val == undefined) return;
			
			_grad_color[i * 4 + 0] = _color_get_red(_val);
			_grad_color[i * 4 + 1] = _color_get_green(_val);
			_grad_color[i * 4 + 2] = _color_get_blue(_val);
			_grad_color[i * 4 + 3] = _color_get_alpha(_val);
			_grad_time[i] = keys[i].time;
			
			if(_grad_color[i * 4 + 3] != 1) aa = true;
		}
		
		surf = surface_verify(surf, _w, _h);
		
		surface_set_target(surf);
			DRAW_CLEAR
			var _gh = aa? _h - ui(8) : _h;
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 4, 0, 0, _w, _gh, c_white, _a)
			
			if(len) {
				BLEND_MULTIPLY
				
				shader_set(sh_gradient_display);
				shader_set_uniform_i(uniform_grad_blend, type);
				shader_set_uniform_f_array_safe(uniform_grad, _grad_color, GRADIENT_LIMIT * 4);
				shader_set_uniform_f_array_safe(uniform_grad_time, _grad_time);
				shader_set_uniform_i(uniform_grad_key, len);
				
				draw_sprite_stretched_ext(s_fx_pixel, 0, 0, 0, _w, _gh, c_white, 1);
				shader_reset();
				
				BLEND_NORMAL
			}
			
			if(aa) {
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 4, 0, _h - ui(6), _w, ui(6), c_white, _a)
				
				BLEND_MULTIPLY
				
				shader_set(sh_gradient_display_alpha);
				shader_set_uniform_i(uniform_grad_blend, type);
				shader_set_uniform_f_array_safe(uniform_grad, _grad_color, GRADIENT_LIMIT * 4);
				shader_set_uniform_f_array_safe(uniform_grad_time, _grad_time);
				shader_set_uniform_i(uniform_grad_key, len);
				
				draw_sprite_stretched_ext(s_fx_pixel, 0, 0, _h - ui(6), _w, ui(6), c_white, 1);
				shader_reset();
				
				BLEND_NORMAL
			}
		surface_reset_target();
		
		draw_surface(surf, _x, _y);
	}
	
	static cache = function(res = 128) {
		cacheRes  = res;
		caches    = array_verify(caches, cacheRes + 1);
		keyLength = array_length(keys);
		
		for( var i = 0; i <= cacheRes; i++ )
			caches[i] = eval(i / cacheRes);
	}
	
	static toArray = function() {
		var _grad_color = [], _grad_time = []; 
		
		for(var i = 0; i < array_length(keys); i++) {
			var _val = keys[i].value;
			if(is_undefined(_val)) continue;
			
			_grad_color[i * 4 + 0] = _color_get_red(_val);
			_grad_color[i * 4 + 1] = _color_get_green(_val);
			_grad_color[i * 4 + 2] = _color_get_blue(_val);
			_grad_color[i * 4 + 3] = _color_get_alpha(_val);
			_grad_time[i] = keys[i].time;
		}
	
		return [ _grad_color, _grad_time ];
	}
	
	static lerpTo = function(target, amount) {
		var grad = new gradientObject();
		grad.keys = [];
		grad.type = type;
		
		var key_count = ceil(lerp(array_length(keys), array_length(target.keys), amount));
		
		if(key_count == 0) return grad;
		if(key_count == 1) {
			grad.keys[0] = new gradientKey(0, merge_color(eval(0), target.eval(0), amount));
			return grad;
		}
		
		for( var i = 0; i < key_count; i++ ) {
			var rat = i / (key_count - 1);
			
			var kf = keys[rat * (array_length(keys) - 1)];
			var kt = target.keys[rat * (array_length(target.keys) - 1)];
			
			var time  = lerp(kf.time, kt.time, amount);
			var value = merge_color(eval(time), target.eval(time), amount);
			
			grad.keys[i] = new gradientKey(time, value);
		}
		
		return grad;
	}
	
	static shader_submit = function(_key = "gradient") {
		var _grad = toArray();
		var _grad_color = _grad[0];
		var _grad_time	= _grad[1];
		
		shader_set_i($"{_key}_blend", type);
		shader_set_f_array($"{_key}_color", _grad_color, GRADIENT_LIMIT * 4);
		shader_set_f($"{_key}_time",  _grad_time);
		shader_set_i($"{_key}_keys",  array_length(keys));
	}
	
	static clone = function() {
		var g = new gradientObject();
		g.keys = [];
		g.type = type;
		
		for( var i = 0, n = array_length(keys); i < n; i++ )
			g.keys[i] = keys[i].clone();
			
		return g;
	}
	
	static serialize = function() {
		var s  = { type, keys: [] };
		for( var i = 0, n = array_length(keys); i < n; i++ )
			s.keys[i] = keys[i].serialize();
		
		return json_stringify(s, false);
	}
	
	static deserialize = function(str) {
		var s;
		
		if(is_array(str)) {			
			keys = [];
			for( var i = 0, n = array_length(str); i < n; i++ )
				keys[i] = new gradientKey(str[i].time, str[i].value); 
			
			return self;
		}
		
		if(is_string(str))		s = json_try_parse(str);
		else if(is_struct(str))	s = str;
		else					return self;
		
		type = struct_try_get(s, "type");
		keys = array_create(array_length(s.keys));
		
		for( var i = 0, n = array_length(s.keys); i < n; i++ ) {
			var _time  = s.keys[i].time;
			var _value = s.keys[i].value;
			
			if(LOADING_VERSION < 11660) _value = cola(_value);
			
			keys[i] = new gradientKey(_time, _value); 
		}
		
		return self;
	}
}

function loadGradient(path) {
	if(path == "") return noone;
	if(!file_exists_empty(path)) return noone;
		
	var grad = new gradientObject();
	grad.keys = [];
		
	var _t = file_text_open_read(path);
	while(!file_text_eof(_t)) {
		var key = string_trim(file_text_readln(_t));
		var _col = 0, _pos = 0;
			
		if(string_pos(",", key)) {
			var keys = string_splice(key, ",");
			if(array_length(keys) < 2) continue;
				
			_col = toNumber(keys[0]);
			_pos = toNumber(keys[1]);
			
		} else {
			_col = toNumber(key);
			if(file_text_eof(_t)) break;
			_pos = toNumber(file_text_readln(_t));
		}
			
		if(!is_int64(_col)) _col = cola(_col);
		array_push(grad.keys, new gradientKey(_pos, _col));
	}
	file_text_close(_t);
	
	return grad;
}
	
function shader_set_gradient(gradient, surface, range, junc) {
	var use_map = junc.attributes.mapped && is_surface(surface);
	
	shader_set_i("gradient_use_map",           use_map);
	shader_set_f("gradient_map_range",         range);
	var t = shader_set_surface("gradient_map", surface);
	gpu_set_tex_filter_ext(t, true);
	
	if(is_instanceof(gradient, gradientObject))
		gradient.shader_submit();
}
	
function evaluate_gradient_map(_x, gradient, surface, range, junc, fast = false) {
	
	var use_map = junc.attributes.mapped;
	if(!use_map) return fast? gradient.evalFast(_x) : gradient.eval(_x);
	
	if(!is_surface(surface)) return 0;
	var _sw = surface_get_width(surface);
	var _sh = surface_get_height(surface);
		
	var _sx = lerp(range[0], range[2], _x) * _sw;
	var _sy = lerp(range[1], range[3], _x) * _sh;
		
	return surface_getpixel_ext(surface, _sx, _sy);
}
	
globalvar GRADIENTS;
GRADIENTS = [];

function __initGradient() {
	GRADIENTS = [];
	
	var path = DIRECTORY + "Gradients/"
	var file = file_find_first(path + "*", 0);
	while(file != "") {
		array_push(GRADIENTS, {
			name:     filename_name_only(file),
			path:     path + file,
			gradient: loadGradient(path + file)
		});
		file = file_find_next();
	}
	file_find_close();
}