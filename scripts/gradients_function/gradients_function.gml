enum GRADIENT_INTER {
	smooth,
	none,
	hue
}

function gradientKey(time, value) constructor {
	self.time  = time;
	self.value = value;
	
	static clone = function() { return new gradientKey(time, value); }
	
	static serialize = function() {
		var m = ds_map_create();
		m[? "time"]  = time;
		m[? "value"] = value;
		return m;
	}
}

function draw_gradient(_x, _y, _w, _h, _grad, _int = GRADIENT_INTER.smooth) {
	static RES = 48;
	var _step  = _w / RES;
	var _ox, _oc;
	
	var uniform_grad_blend = shader_get_uniform(sh_gradient_display, "gradient_blend");
	var uniform_grad = shader_get_uniform(sh_gradient_display, "gradient_color");
	var uniform_grad_time = shader_get_uniform(sh_gradient_display, "gradient_time");
	var uniform_grad_key = shader_get_uniform(sh_gradient_display, "gradient_keys");
	
	var _grad_color = [];
	var _grad_time  = [];
	
	for(var i = 0; i < array_length(_grad); i++) {
		if(_grad[i].value == undefined) return;
		
		_grad_color[i * 4 + 0] = color_get_red(_grad[i].value) / 255;
		_grad_color[i * 4 + 1] = color_get_green(_grad[i].value) / 255;
		_grad_color[i * 4 + 2] = color_get_blue(_grad[i].value) / 255;
		_grad_color[i * 4 + 3] = 1;
		_grad_time[i]  = _grad[i].time;
	}
	
	if(array_length(_grad) == 0) {
		draw_sprite_stretched(s_fx_pixel, 0, _x, _y, _w, _h)
	} else {
		shader_set(sh_gradient_display);
		shader_set_uniform_i(uniform_grad_blend, _int);
		shader_set_uniform_f_array_safe(uniform_grad, _grad_color);
		shader_set_uniform_f_array_safe(uniform_grad_time, _grad_time);
		shader_set_uniform_i(uniform_grad_key, array_length(_grad));
			
		draw_sprite_stretched(s_fx_pixel, 0, _x, _y, _w, _h)
		shader_reset();
	}
}

function gradient_eval(_gradient, _time, _int = GRADIENT_INTER.smooth) {
	if(array_length(_gradient) == 0) return c_white;
	if(array_length(_gradient) == 1) return _gradient[0].value;
	
	for(var i = 0; i < array_length(_gradient); i++) {
		var _key = _gradient[i];
		if(_key.time < _time) continue;
		if(_key.time == _time) return _gradient[i].value;
		
		if(i == 0) //before first color
			return _gradient[0].value;
		
		var c0 = _gradient[i - 1].value;
		if(_int == GRADIENT_INTER.smooth) {
			var rat = (_time - _gradient[i - 1].time) / (_gradient[i].time - _gradient[i - 1].time);
			var c1 = _gradient[i].value;
			return merge_color(c0, c1, rat);
		} else if(_int == GRADIENT_INTER.none) {
			return c0;
		}
	}
	
	return _gradient[array_length(_gradient) - 1].value; //after last color
}

function gradient_add(_gradient, _addkey, _deleteDup) {
	if(array_length(_gradient) == 0) {
		array_push(_gradient, _addkey);
		return;
	}
		
	for(var i = 0; i < array_length(_gradient); i++) {
		var _key = _gradient[i];
		
		if(_key.time == _addkey.time) {
			if(_deleteDup)
				_key.value = _addkey.value;
			return;
		} else if(_key.time > _addkey.time) {
			array_insert(_gradient, i, _addkey);
			return;
		}
	}
		
	array_push(_gradient, _addkey);
}

function gradient_to_array(_gradient) {
	var _grad_color = [], _grad_time = []; 
	
	for(var i = 0; i < array_length(_gradient); i++) {
		if(is_undefined(_gradient[i].value)) continue;
		
		_grad_color[i * 4 + 0] = color_get_red(_gradient[i].value) / 255;
		_grad_color[i * 4 + 1] = color_get_green(_gradient[i].value) / 255;
		_grad_color[i * 4 + 2] = color_get_blue(_gradient[i].value) / 255;
		_grad_color[i * 4 + 3] = 1;
		_grad_time[i]  = _gradient[i].time;
	}
	
	return [ _grad_color, _grad_time ];
}