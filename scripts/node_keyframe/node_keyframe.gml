enum CURVE_TYPE {
	none,
	bezier,
}

function valueKey(_time, _value, _anim = noone, _in = 0, _ot = 0) constructor {
	time	= _time;
	ratio	= time / (ANIMATOR.frames_total - 1);
	value	= _value;
	anim	= _anim;
	
	ease_in	 = is_array(_in)? _in : [_in, 1];
	ease_out = is_array(_ot)? _ot : [_ot, 0];
	
	ease_in_type  = CURVE_TYPE.none;
	ease_out_type = CURVE_TYPE.none;
	
	static setTime = function(time) {
		self.time = time;	
		ratio	= time / (ANIMATOR.frames_total - 1);
	}
}

function valueAnimator(_val, _prop) constructor {
	values  = ds_list_create();
	show_graph = false;
	ds_list_add(values, new valueKey(0, _val, self));
	
	is_anim  = false;
	prop     = _prop;
	
	static interpolate = function(from, to, rat) {
		if(to.ease_in_type == CURVE_TYPE.none && from.ease_out_type == CURVE_TYPE.none) 
			return rat;
		if(rat == 0 || rat == 1) 
			return rat;
		
		var eox = clamp(from.ease_out[0], 0, 0.9);
		var eix = clamp(to.ease_in[0],    0, 0.9);
		var eoy = from.ease_out[1];
		var eiy = to.ease_in[1];
		
		var bz = [0, eox, eoy, 1. - eix, eiy, 1];
		return eval_curve_bezier_cubic_x(bz, rat);
		
		//var eo = rat;
		//var ei = rat;
		
		//if(from.ease_out != 0) {
		//	switch(from.ease_out_type) {
		//		case CURVE_TYPE.bezier : 
		//			eo = ease_cubic_in(rat);
		//			eo = lerp(rat, eo, from.ease_out);
		//			break;
		//		case CURVE_TYPE.damping : 
		//			eo = ease_damp_in(rat, 1 + from.ease_out * 10);
		//			break;
		//	}
		//}
		
		//if(to.ease_in != 0) {
		//	switch(to.ease_in_type) {
		//		case CURVE_TYPE.bezier  : 
		//			ei = ease_cubic_out(rat);
		//			ei = lerp(rat, ei, to.ease_in);
		//			break;
		//		case CURVE_TYPE.damping : 
		//			ei = ease_damp_out(rat, 1 + to.ease_in * 10);
		//			break;
		//	}
		//}
		
		//if(from.ease_out_type == CURVE_TYPE.damping && to.ease_in_type == CURVE_TYPE.damping) 
		//	return lerp(eo, ei, rat < 0.5 ? 4 * power(rat, 3) : 1 - power(-2 * rat + 2, 3) / 2);
		
		//return lerp(eo, ei, rat);
	}
	
	static lerpValue = function(from, to, _lrp) {
		if(prop.type == VALUE_TYPE.color) {
			var _f = from.value;
			var _t = to.value;
			
			if(is_array(_f)) {
				var amo = max(array_length(_f), array_length(_t));
				var res = array_create(amo);
				for( var i = 0; i < amo; i++ )
					res[i] = merge_color(array_safe_get(_f, i, 0), array_safe_get(_t, i, 0), _lrp);
				
				return res;
			}
			
			return processType(merge_color(_f, _t, _lrp));
		}
			
		if(typeArray(prop.display_type) && is_array(from.value)) {
			var _vec = array_create(array_length(from.value));
			for(var i = 0; i < array_length(_vec); i++) 
				_vec[i] = processType(lerp(from.value[i], to.value[i], _lrp));
			return _vec;
		}
			
		if(prop.type == VALUE_TYPE.text)
			return processType(from.value);
			
		return processType(lerp(from.value, to.value, _lrp));
	}
	
	static getValue = function(_time = ANIMATOR.current_frame) {
		if(prop.display_type == VALUE_DISPLAY.gradient) return processType(values);
		if(prop.type == VALUE_TYPE.path) return processType(values[| 0].value);
		
		if(ds_list_size(values) == 0) return processType(0);
		if(ds_list_size(values) == 1) return processType(values[| 0].value);
		if(!is_anim) return processType(values[| 0].value);
		
		var _time_first = values[| 0].time;
		var _time_last  = values[| ds_list_size(values) - 1].time;
		var _time_dura  = _time_last - _time_first;
			
		if(_time > _time_last) {
			switch(prop.on_end) {
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
		
		if(_time < values[| 0].time) { //Wrap begin
			if(prop.on_end == KEYFRAME_END.wrap) {
				var from = values[| ds_list_size(values) - 1];
				var to   = values[| 0];
				var prog = ANIMATOR.frames_total - from.time + _time;
				var totl = ANIMATOR.frames_total - from.time + to.time;
				
				var rat  = prog / totl;
				var _lrp = interpolate(from, to, rat);
				
				return lerpValue(from, to, _lrp);
			}
			
			return processType(values[| 0].value); //First frame
		}
			
		for(var i = 0; i < ds_list_size(values); i++) { //In between
			var _key = values[| i];
			if(_key.time <= _time) continue;
			
			var rat  = (_time - values[| i - 1].time) / (values[| i].time - values[| i - 1].time);
			var from = values[| i - 1];
			var to   = values[| i];
			var _lrp = interpolate(from, to, rat);
			
			return lerpValue(from, to, _lrp);
		}
		
		if(prop.on_end == KEYFRAME_END.wrap) { //Wrap end
			var from = values[| ds_list_size(values) - 1];
			var to   = values[| 0];
			var prog = _time - from.time;
			var totl = ANIMATOR.frames_total - from.time + to.time;
				
			var rat  = prog / totl;
			var _lrp = interpolate(from, to, rat);
				
			return lerpValue(from, to, _lrp);
		}
		
		return processType(values[| ds_list_size(values) - 1].value); //Last frame
	}
	
	static processType = function(_val) {
		if(typeArray(prop.display_type) && is_array(_val)) {
			for(var i = 0; i < array_length(_val); i++) 
				_val[i] = processValue(_val[i]);			
			return _val;
		}
		return processValue(_val);
	}
	
	static processValue = function(_val) {
		if(is_array(_val)) return _val;
		
		if(prop.type == VALUE_TYPE.integer && prop.unit.mode == VALUE_UNIT.constant)
			return round(toNumber(_val));
			
		switch(prop.type) {
			case VALUE_TYPE.integer : 
			case VALUE_TYPE.float   : return toNumber(_val);
			case VALUE_TYPE.text    : return string(_val);
			case VALUE_TYPE.surface : 
				if(is_string(_val))
					return get_asset(_val);
				return is_surface(_val)? _val : DEF_SURFACE;
		}
		
		return _val;
	}
	
	static setKeyTime = function(_key, _time, _replace = true) {
		if(!ds_list_exist(values, _key)) return 0;
		MODIFIED = true;
		
		_time = clamp(_time, 0, ANIMATOR.frames_total - 1);
		_key.setTime(_time);
		ds_list_remove(values, _key);
		
		if(_replace) {
			for( var i = 0; i < ds_list_size(values); i++ ) {
				if(values[| i].time == _time) {
					values[| i] = _key;
					return 2;
				}
			}
		}
		
		for( var i = 0; i < ds_list_size(values); i++ ) {
			if(values[| i].time > _time) {
				ds_list_insert(values, i, _key);
				return 1;
			}
		}
		
		ds_list_add(values, _key);
		return 1;
	}
	
	static setValue = function(_val = 0, _record = true, _time = ANIMATOR.current_frame, ease_in = 0, ease_out = 0) {
		MODIFIED = true;
		
		if(!is_anim) {
			if(isEqual(values[| 0].value, _val)) 
				return false;
			
			if(_record)
				recordAction(ACTION_TYPE.var_modify, values[| 0], [ values[| 0].value, "value" ]);
			values[| 0].value = _val;
			return true;
		}
		
		if(ds_list_size(values) == 0) {
			var k = new valueKey(_time, _val, self, ease_in, ease_out);
			ds_list_add(values, k);
			if(_record)
				recordAction(ACTION_TYPE.list_insert, values, [ k, ds_list_size(values) - 1 ]);
			return true;
		}
		
		for(var i = 0; i < ds_list_size(values); i++) {
			var _key = values[| i];
			if(_key.time == _time) {
				if(_record) 
					recordAction(ACTION_TYPE.var_modify, _key, [ _key.value, "value" ]);
				if(_key.value != _val) {
					_key.value = _val;
					return true;
				}
				return false;
			} else if(_key.time > _time) {
				var k = new valueKey(_time, _val, self, ease_in, ease_out);
				ds_list_insert(values, i, k);
				if(_record)
					recordAction(ACTION_TYPE.list_insert, values, [k, i]);
				return true;
			}
		}
		
		var k = new valueKey(_time, _val, self, ease_in, ease_out);
		ds_list_add(values, k);
		if(_record)
			recordAction(ACTION_TYPE.list_insert, values, [ k, ds_list_size(values) - 1 ]);
		return true;
	}
	
	static removeKey = function(key) {
		if(ds_list_size(values) > 1)
			ds_list_remove(values, key);
		else
			is_anim = false;
	}
	
	static serialize = function(scale = false) {
		var _list = ds_list_create();
		
		for(var i = 0; i < ds_list_size(values); i++) {
			var _value_list = ds_list_create();
			if(scale && prop.display_type != VALUE_DISPLAY.gradient)
				_value_list[| 0] = values[| i].time / (ANIMATOR.frames_total - 1);
			else
				_value_list[| 0] = values[| i].time;
			
			if(typeArray(prop.display_type) && is_array(values[| i].value)) {
				var __v = ds_list_create();
				for(var j = 0; j < array_length(values[| i].value); j++)
					ds_list_add(__v, values[| i].value[j]);
				_value_list[| 1] = __v;
				ds_list_mark_as_list(_value_list, 1);
			} else {
				_value_list[| 1] = values[| i].value;
			}
			
			_value_list[| 2] = ds_list_create_from_array(values[| i].ease_in);
				ds_list_mark_as_list(_value_list, 2);
			_value_list[| 3] = ds_list_create_from_array(values[| i].ease_out);
				ds_list_mark_as_list(_value_list, 3);
				
			_value_list[| 4] = values[| i].ease_in_type;
			_value_list[| 5] = values[| i].ease_out_type;
			
			ds_list_add_list(_list, _value_list);
		}
		
		return _list;
	}
	
	static deserialize = function(_list, scale = false) {
		var base = getValue();
		ds_list_clear(values);
		
		for(var i = 0; i < ds_list_size(_list); i++) {
			var _key  = _list[| i];
			var _time = _key[| 0];
			if(prop.display_type == VALUE_DISPLAY.gradient) 
				_time = _key[| 0];
			else if(scale && _key[| 0] <= 1)
				_time = round(_key[| 0] * (ANIMATOR.frames_total - 1));
			
			var value    = ds_list_get(_key, 1);
			var ease_in  = ds_list_get(_key, 2);
			var ease_out = ds_list_get(_key, 3);
			if(LOADING_VERSION >= 1090) {
				ease_in  = array_create_from_list(ease_in);
				ease_out = array_create_from_list(ease_out);
			}
			
			var ease_in_type  = ds_list_get(_key, 4, CURVE_TYPE.bezier);
			var ease_out_type = ds_list_get(_key, 5, CURVE_TYPE.bezier);
			var _val  = _key[| 1];
			
			if(prop.type == VALUE_TYPE.path && prop.display_type == VALUE_DISPLAY.path_array) {
				for(var j = 0; j < ds_list_size(value); j++)
					_val[j] = value[| j];
			} else if(typeArray(prop.display_type) && is_array(base)) {
				_val = array_create(array_length(base));
					
				if(ds_exists(_key[| 1], ds_type_list)) {
					for(var j = 0; j < ds_list_size(_key[| 1]); j++)
						_val[j] = processValue(value[| j]);
				}
			} 
			
			var vk = new valueKey(_time, _val, self, ease_in, ease_out);
			vk.ease_in_type  = ease_in_type;
			vk.ease_out_type = ease_out_type;
			ds_list_add(values, vk);
		}
	}
	
	static cleanUp = function() {
		ds_list_destroy(values);
	}
}