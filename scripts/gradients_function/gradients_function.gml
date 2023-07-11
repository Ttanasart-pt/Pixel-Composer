enum GRADIENT_INTER {
	smooth,
	none,
	hue
}

function gradientKey(time, value) constructor {
	self.time  = time;
	self.value = value;
	
	static clone = function() { return new gradientKey(time, value); }
	
	static serialize = function() { return {time, value}; }
}

function gradientObject(color = c_black) constructor {
	if(is_array(color))
		keys = [ new gradientKey(0, color[0]), new gradientKey(1, color[1]) ];
	else
		keys = [ new gradientKey(0, color) ];
	type = GRADIENT_INTER.smooth;
	
	static clone = function() {
		var g = new gradientObject();
		for( var i = 0; i < array_length(keys); i++ ) {
			g.keys[i] = keys[i].clone();
		}
		g.type = type;
		
		return g;
	}
	
	static add = function(_addkey, _deleteDup = true) {
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
		if(array_length(keys) == 0) return c_black;
		if(array_length(keys) == 1) return keys[0].value;
	
		for(var i = 0; i < array_length(keys); i++) {
			var _key = keys[i];
			if(_key.time < position) continue;
			if(_key.time == position) return keys[i].value;
		
			if(i == 0) //before first color
				return keys[0].value;
		
			var c0 = keys[i - 1].value;
			if(type == GRADIENT_INTER.smooth) {
				var rat = (position - keys[i - 1].time) / (keys[i].time - keys[i - 1].time);
				var c1 = keys[i].value;
				return merge_color(c0, c1, rat);
			} else if(type == GRADIENT_INTER.none) {
				return c0;
			}
		}
	
		return keys[array_length(keys) - 1].value; //after last color
	}
	
	static draw = function(_x, _y, _w, _h, _a = 1) {
		var uniform_grad_blend	= shader_get_uniform(sh_gradient_display, "gradient_blend");
		var uniform_grad		= shader_get_uniform(sh_gradient_display, "gradient_color");
		var uniform_grad_time	= shader_get_uniform(sh_gradient_display, "gradient_time");
		var uniform_grad_key	= shader_get_uniform(sh_gradient_display, "gradient_keys");
	
		var _grad_color = [];
		var _grad_time  = [];
	
		for(var i = 0; i < array_length(keys); i++) {
			if(keys[i].value == undefined) return;
		
			_grad_color[i * 4 + 0] = color_get_red(keys[i].value) / 255;
			_grad_color[i * 4 + 1] = color_get_green(keys[i].value) / 255;
			_grad_color[i * 4 + 2] = color_get_blue(keys[i].value) / 255;
			_grad_color[i * 4 + 3] = 1;
			_grad_time[i]  = keys[i].time;
		}
	
		if(array_length(keys) == 0) {
			draw_sprite_stretched_ext(s_fx_pixel, 0, _x, _y, _w, _h, c_white, _a)
		} else {
			shader_set(sh_gradient_display);
			shader_set_uniform_i(uniform_grad_blend, type);
			shader_set_uniform_f_array_safe(uniform_grad, _grad_color);
			shader_set_uniform_f_array_safe(uniform_grad_time, _grad_time);
			shader_set_uniform_i(uniform_grad_key, array_length(keys));
			
			draw_sprite_stretched_ext(s_fx_pixel, 0, _x, _y, _w, _h, c_white, _a)
			shader_reset();
		}
	}
	
	static toArray = function() {
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
	}
	
	static lerpTo = function(target, amount) {
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
	}
	
	static clone = function() {
		var g = new gradientObject();
		g.keys = [];
		g.type = type;
		
		for( var i = 0; i < array_length(keys); i++ )
			g.keys[i] = keys[i].clone();
			
		return g;
	}
	
	static serialize = function() {
		var s = {type};
		s.keys = [];
		for( var i = 0; i < array_length(keys); i++ )
			s.keys[i] = keys[i].serialize();
			
		return json_stringify(s, false);
	}
	
	static deserialize = function(str) {
		var s;
		
		if(is_string(str))
			s = json_try_parse(str);
		else if(is_struct(str))
			s = str;
		else if(is_array(str)) {			
			keys = [];
			for( var i = 0; i < array_length(str); i++ )
				keys[i] = new gradientKey(str[i].time, str[i].value); 
			
			return self;
		}
			
		type = s.type;
		keys = [];
		for( var i = 0; i < array_length(s.keys); i++ )
			keys[i] = new gradientKey(s.keys[i].time, s.keys[i].value); 
		
		return self;
	}
}

function loadGradient(path) {
	if(path == "") return noone;
	if(!file_exists(path)) return noone;
		
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
}