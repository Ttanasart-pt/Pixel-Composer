enum CURVE_TYPE {
	bezier,
	bounce,
	damping
}

globalvar ON_END_NAME;
ON_END_NAME = [ "Hold", "Loop", "Ping pong" ];

function valueKey(_time, _value, _in = 0, _out = 0) constructor {
	time = _time;
	value = _value;
	
	ease_in = _in;
	ease_out = _out;
}

function animValue(_val, _node) constructor {
	values  = ds_list_create();
	show_graph = false;
	ds_list_add(values, new valueKey(0, _val));
	
	is_anim    = false;
	node       = _node;
	
	static interpolate = function(from, to, rat) {
		var _lerp;
		if(from.ease_out == 0 && to.ease_in == 0) 
			_lerp = rat;
		else {
			var a = from.ease_out;
			var b = 1 - to.ease_in;
			
			_lerp = bezier_interpol_x(a, b, rat);
		}
		
		return _lerp;
	}
	
	static getValue = function() {
		if(node.display_type == VALUE_DISPLAY.gradient) return processType(values);
		if(node.type == VALUE_TYPE.path) return processType(values[| 0].value);
		
		if(!is_anim) return processType(values[| 0].value);
		if(ds_list_size(values) == 0) return processType(0);
		if(ds_list_size(values) == 1) return processType(values[| 0].value);
		
		var _time = argument_count > 0? argument[0] : ANIMATOR.current_frame;
		
		if(ds_list_size(values) > 1) {
			var _time_first = values[| 0].time;
			var _time_last  = values[| ds_list_size(values) - 1].time;
			var _time_dura  = _time_last - _time_first;
			
			if(_time > _time_last) {
				switch(node.on_end) {
					case KEYFRAME_END.loop : 
						_time = _time_first + safe_mod(_time - _time_last, _time_dura + 1);
						break;
					case KEYFRAME_END.ping :
						var time_in_loop = safe_mod(_time - _time_first, _time_dura * 2);
						if(time_in_loop < _time_dura) 
							_time = _time_first + time_in_loop;
						else
							_time = _time_first + _time_dura * 2 - time_in_loop;
						break;
				}
			}
		}
		
		for(var i = 0; i < ds_list_size(values); i++) {
			var _key = values[| i];
			if(_key.time > _time) {
				if(i == 0) 
					return processType(values[| 0].value);
				else {
					var rat = (_time - values[| i - 1].time) / (values[| i].time - values[| i - 1].time);
					var from = values[| i - 1];
					var to = values[| i];
					var _lerp = interpolate(from, to, rat);
						
					if(node.type == VALUE_TYPE.color) {
						return processType(merge_color(from.value, to.value, _lerp));
					} else if(typeArray(node.display_type)) {
						var _vec = array_create(array_length(from.value));
						for(var i = 0; i < array_length(_vec); i++) 
							_vec[i] = processType(lerp(from.value[i], to.value[i], _lerp));
						return _vec;
					} else if(node.type == VALUE_TYPE.text) {
						return processType(from.value);
					} else {
						return processType(lerp(from.value, to.value, _lerp));
					}
				}
			}
		}
		return processType(values[| ds_list_size(values) - 1].value);
	}
	
	static processType = function(_val) {
		if(typeArray(node.display_type)) {
			for(var i = 0; i < array_length(_val); i++) 
				_val[i] = processValue(_val[i]);			
			return _val;
		}
		return processValue(_val);
	}
	static processValue = function(_val) {
		if(is_array(_val)) return _val;
		
		switch(node.type) {
			case VALUE_TYPE.integer : return round(_val);	
			case VALUE_TYPE.float   : return _val;
			case VALUE_TYPE.text    : return string(_val);
			case VALUE_TYPE.surface : return _val == 0? DEF_SURFACE : _val;
		}
		
		return _val;
	}
	
	static setValue = function(_val = 0, _record = true, _time = -999, ease_in = 0, ease_out = 0) {
		if(_time == -999) _time = ANIMATOR.current_frame;
		
		if(!is_anim) {
			if(_record) recordAction(ACTION_TYPE.var_modify, values[| 0], [ values[| 0].value, "value" ]);
			if(values[| 0].value != _val) {
				values[| 0].value = _val;
				return true;
			}
			return false;
		}
		
		if(ds_list_size(values) == 0) {
			var k = new valueKey(_time, _val, ease_in, ease_out);
			ds_list_add(values, k);
			if(_record)
				recordAction(ACTION_TYPE.list_insert, values, [ k, ds_list_size(values) - 1 ]);
			return true;
		}
		
		for(var i = 0; i < ds_list_size(values); i++) {
			var _key = values[| i];
			if(_key.time == _time) {
				if(_record) recordAction(ACTION_TYPE.var_modify, _key, [ _key.value, "value" ]);
				if(_key.value != _val) {
					_key.value = _val;
					return true;
				}
				return false;
			} else if(_key.time > _time) {
				var k = new valueKey(_time, _val, ease_in, ease_out);
				ds_list_insert(values, i, k);
				if(_record)
					recordAction(ACTION_TYPE.list_insert, values, [k, i]);
				return true;
			}
		}
		
		var k = new valueKey(_time, _val, ease_in, ease_out);
		ds_list_add(values, k);
		if(_record)
			recordAction(ACTION_TYPE.list_insert, values, [ k, ds_list_size(values) - 1 ]);
		return true;
	}
	
	static serialize = function(scale = false) {
		var _list = ds_list_create();
		
		for(var i = 0; i < ds_list_size(values); i++) {
			var _value_list = ds_list_create();
			if(scale && node.display_type != VALUE_DISPLAY.gradient)
				_value_list[| 0] = values[| i].time / ANIMATOR.frames_total;
			else
				_value_list[| 0] = values[| i].time;
			
			if(typeArray(node.display_type)) {
				var __v = ds_list_create();
				for(var j = 0; j < array_length(values[| i].value); j++)
					ds_list_add(__v, values[| i].value[j]);
				_value_list[| 1] = __v;
				ds_list_mark_as_list(_value_list, 1);
			} else {
				_value_list[| 1] = values[| i].value;
			}
			
			_value_list[| 2] = values[| i].ease_in;
			_value_list[| 3] = values[| i].ease_out;
			
			ds_list_add(_list, _value_list);
			ds_list_mark_as_list(_list, i);
		}
		
		return _list;
	}
	
	static deserialize = function(_list, scale = false) {
		var base = getValue();
		ds_list_clear(values);
		for(var i = 0; i < ds_list_size(_list); i++) {
			var _key  = _list[| i];
			var _time = _key[| 0];
			if(node.display_type == VALUE_DISPLAY.gradient) 
				_time = _key[| 0];
			else if(scale && _key[| 0] <= 1)
				_time = round(_key[| 0] * ANIMATOR.frames_total);
			
			var ease_in = ds_list_get(_key, 2);
			var ease_out = ds_list_get(_key, 3);
			var _val;
			var t = typeArray(node.display_type);
			
			if(t) {
				if(is_string(_key[| 1])) {
					_val = compat_path_array(_key[| 1]);
				} else {
					if(ds_exists(_key[| 1], ds_type_list)) {
						var ll = t == 1? min(array_length(base), ds_list_size(_key[| 1])) : ds_list_size(_key[| 1]);
						_val = array_create(ll);
						for(var j = 0; j < ll; j++)
							_val[j] = _key[| 1][| j];
					} else {
						_val = array_create(array_length(base), _key[| 1]);
					}
				}
			} else {
				_val  = _key[| 1];
			}
			
			ds_list_add(values, new valueKey(_time, _val, ease_in, ease_out));
		}
	}
	
	static cleanUp = function() {
		ds_list_destroy(values);
	}
}