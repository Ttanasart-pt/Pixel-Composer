enum GRADIENT_INTER {
	smooth,
	none,
	hue
}

function gradientKey(time, value) constructor { #region
	self.time  = time;
	self.value = value;
	
	static clone = function() { return new gradientKey(time, value); }
	static serialize = function() { return { time, value }; }
} #endregion

function gradientObject(color = c_black) constructor { #region
	static GRADIENT_LIMIT = 128;
	
	if(is_array(color)) keys = [ new gradientKey(0, color[0]), new gradientKey(1, color[1]) ];
	else				keys = [ new gradientKey(0, color) ];
	type = GRADIENT_INTER.smooth;
	surf = noone;
	
	static clone = function() { #region
		var g = new gradientObject();
		for( var i = 0, n = array_length(keys); i < n; i++ )
			g.keys[i] = keys[i].clone();
		g.type = type;
		
		return g;
	} #endregion
	
	static add = function(_addkey, _deleteDup = true) { #region
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
	} #endregion
	
	static eval = function(position) { #region
		var _len = array_length(keys);
		if(_len == 0) return c_black;
		if(_len == 1) return keys[0].value;
	
		if(position <= keys[0].time)        return keys[0].value;
		if(position >= keys[_len - 1].time) return keys[_len - 1].value;
		
		var _pkey = keys[0];
		
		for(var i = 1; i < _len; i++) {
			var _key = keys[i];
			if(_key.time < position) continue;
			if(_key.time == position) return keys[i].value;
			
			if(type == GRADIENT_INTER.smooth) {
				var rat = (position - _pkey.time) / (_key.time - _pkey.time);
				return merge_color(_pkey.value, _key.value, rat);
			} else if(type == GRADIENT_INTER.none) {
				return _pkey.value;
			}
			
			_pkey = _key;
		}
	
		return keys[array_length(keys) - 1].value; //after last color
	} #endregion
	
	static draw = function(_x, _y, _w, _h, _a = 1) { #region
		var uniform_grad_blend	= shader_get_uniform(sh_gradient_display, "gradient_blend");
		var uniform_grad		= shader_get_uniform(sh_gradient_display, "gradient_color");
		var uniform_grad_time	= shader_get_uniform(sh_gradient_display, "gradient_time");
		var uniform_grad_key	= shader_get_uniform(sh_gradient_display, "gradient_keys");
	
		var _grad_color = [];
		var _grad_time  = [];
		
		var len = min(128, array_length(keys));
		
		for(var i = 0; i < len; i++) {
			if(keys[i].value == undefined) return;
		
			_grad_color[i * 4 + 0] = color_get_red(keys[i].value)   / 255;
			_grad_color[i * 4 + 1] = color_get_green(keys[i].value) / 255;
			_grad_color[i * 4 + 2] = color_get_blue(keys[i].value)  / 255;
			_grad_color[i * 4 + 3] = 1;
			_grad_time[i] = keys[i].time;
		}
		
		surf = surface_verify(surf, _w, _h);
		
		surface_set_target(surf);
			DRAW_CLEAR
			
			gpu_set_colorwriteenable(0, 0, 0, 1);
				draw_sprite_stretched_ext(THEME.gradient_mask, 0, 0, 0, _w, _h, c_white, _a)
			gpu_set_colorwriteenable(1, 1, 1, 0);
			
			if(len == 0) {
				draw_sprite_stretched_ext(s_fx_pixel, 0, 0, 0, _w, _h, c_white, 1);
			} else {
				shader_set(sh_gradient_display);
				shader_set_uniform_i(uniform_grad_blend, type);
				shader_set_uniform_f_array_safe(uniform_grad, _grad_color, GRADIENT_LIMIT * 4);
				shader_set_uniform_f_array_safe(uniform_grad_time, _grad_time);
				shader_set_uniform_i(uniform_grad_key, len);
			
				draw_sprite_stretched_ext(s_fx_pixel, 0, 0, 0, _w, _h, c_white, 1);
				shader_reset();
			}
			
			gpu_set_colorwriteenable(1, 1, 1, 1);
		surface_reset_target();
		
		draw_surface(surf, _x, _y);
	} #endregion
	
	static toArray = function() { #region
		var _grad_color = [], _grad_time = []; 
		
		for(var i = 0; i < array_length(keys); i++) {
			if(is_undefined(keys[i].value)) continue;
			
			_grad_color[i * 4 + 0] = color_get_red(keys[i].value) / 255;
			_grad_color[i * 4 + 1] = color_get_green(keys[i].value) / 255;
			_grad_color[i * 4 + 2] = color_get_blue(keys[i].value) / 255;
			_grad_color[i * 4 + 3] = 1;
			_grad_time[i] = keys[i].time;
		}
	
		return [ _grad_color, _grad_time ];
	} #endregion
	
	static lerpTo = function(target, amount) { #region
		var grad = new gradientObject();
		grad.keys = [];
		grad.type = type;
		
		var key_count = ceil(lerp(array_length(keys), array_length(target.keys), amount));
		
		for( var i = 0; i < key_count; i++ ) {
			var rat = i / (key_count - 1);
			
			var kf = keys[rat * (array_length(keys) - 1)];
			var kt = target.keys[rat * (array_length(target.keys) - 1)];
			
			var time  = lerp(kf.time, kt.time, amount);
			var value = merge_color(eval(time), target.eval(time), amount);
			
			grad.keys[i] = new gradientKey(time, value);
		}
		
		return grad;
	} #endregion
	
	static shader_submit = function() { #region
		var _grad = toArray();
		var _grad_color = _grad[0];
		var _grad_time	= _grad[1];
		
		shader_set_i("gradient_blend", type);
		shader_set_f("gradient_color", _grad_color);
		shader_set_f("gradient_time",  _grad_time);
		shader_set_i("gradient_keys",  array_length(keys));
	} #endregion
	
	static clone = function() { #region
		var g = new gradientObject();
		g.keys = [];
		g.type = type;
		
		for( var i = 0, n = array_length(keys); i < n; i++ )
			g.keys[i] = keys[i].clone();
			
		return g;
	} #endregion
	
	static serialize = function() { #region
		var s = { type: type };
		s.keys = [];
		for( var i = 0, n = array_length(keys); i < n; i++ )
			s.keys[i] = keys[i].serialize();
			
		return json_stringify(s, false);
	} #endregion
	
	static deserialize = function(str) { #region
		var s;
		
		if(is_string(str))
			s = json_try_parse(str);
		else if(is_struct(str))
			s = str;
		else if(is_array(str)) {			
			keys = [];
			for( var i = 0, n = array_length(str); i < n; i++ )
				keys[i] = new gradientKey(str[i].time, str[i].value); 
			
			return self;
		}
			
		type = struct_try_get(s, "type");
		keys = array_create(array_length(s.keys));
		for( var i = 0, n = array_length(s.keys); i < n; i++ ) {
			var _time  = real(s.keys[i].time);
			var _value = real(s.keys[i].value);
			
			keys[i] = new gradientKey(_time, _value); 
		}
		
		return self;
	} #endregion
} #endregion

function loadGradient(path) { #region
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
			
		array_push(grad.keys, new gradientKey(_pos, _col));
	}
	file_text_close(_t);
	
	return grad;
} #endregion
	
globalvar GRADIENTS;
GRADIENTS = [];

function __initGradient() { #region
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
} #endregion