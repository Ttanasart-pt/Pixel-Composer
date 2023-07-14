enum CURVE_TYPE {
	none,
	bezier,
	cut,
}

function valueKey(_time, _value, _anim = noone, _in = 0, _ot = 0) constructor {
	time	= _time;
	ratio	= time / (PROJECT.animator.frames_total - 1);
	value	= _value;
	anim	= _anim;
	
	ease_y_lock = true;
	ease_in	 = is_array(_in)? _in : [_in, 1];
	ease_out = is_array(_ot)? _ot : [_ot, 0];
	
	ease_in_type  = CURVE_TYPE.none;
	ease_out_type = CURVE_TYPE.none;
	
	dopesheet_x = 0;
	
	static setTime = function(time) {
		self.time = time;	
		ratio	= time / (PROJECT.animator.frames_total - 1);
	}
	
	static clone = function(target = noone) {
		var key = new valueKey(time, value, target);
		key.ease_in			= ease_in;
		key.ease_out		= ease_out;
		key.ease_in_type	= ease_in_type;
		key.ease_out_type	= ease_out_type;
		
		return key;
	}
	
	static cloneAnimator = function(shift = 0, anim = noone, removeDup = true) {
		if(anim != noone) { //check value compat between animator
			if(value_bit(self.anim.prop.type) & value_bit(anim.prop.type) == 0) {
				noti_warning("Type incompatible");
				return noone;
			}
			
			if(typeArray(self.anim.prop.display_type) != typeArray(anim.prop.display_type)) {
				noti_warning("Type incompatible");
				return noone;
			}
		}
		
		if(anim == noone) anim = self.anim;
		
		var key = new valueKey(time + shift, value, anim);
		key.ease_in			= ease_in;
		key.ease_out		= ease_out;
		key.ease_in_type	= ease_in_type;
		key.ease_out_type	= ease_out_type;
		ds_list_add(anim.values, key);
		anim.setKeyTime(key, time + shift, removeDup);
		
		return key;
	}
}

function valueAnimator(_val, _prop, _sep_axis = false) constructor {
	suffix   = "";
	values	 = ds_list_create();
	sep_axis = _sep_axis;
	if(_prop.type != VALUE_TYPE.trigger)
		ds_list_add(values, new valueKey(0, _val, self));
	//print(_prop.name + ": " + string(_val));
	
	index	 = 0;
	prop     = _prop;
	dopesheet_y = 0;
	
	static interpolate = function(from, to, rat) {
		if(prop.type == VALUE_TYPE.boolean)
			return 0;
			
		if(to.ease_in_type == CURVE_TYPE.none && from.ease_out_type == CURVE_TYPE.none) 
			return rat;
		if(to.ease_in_type == CURVE_TYPE.cut) 
			return 0;
		if(from.ease_out_type == CURVE_TYPE.cut) 
			return 1;
		if(rat == 0 || rat == 1) 
			return rat;
		
		var eox = clamp(from.ease_out[0], 0, 0.9);
		var eix = clamp(to.ease_in[0],    0, 0.9);
		var eoy = from.ease_out[1];
		var eiy = to.ease_in[1];
		
		var bz = [0, eox, eoy, 1. - eix, eiy, 1];
		return eval_curve_segment_x(bz, rat);
	}
	
	static lerpValue = function(from, to, _lrp) {
		var _f = from.value;
		var _t = to.value;
		
		if(is_struct(_f)) {
			if(!struct_has(_f, "lerpTo")) return _f;
			return _f.lerpTo(_t, _lrp);
		}
			
		if(prop.type == VALUE_TYPE.color) {
			if(is_array(_f) && is_array(_t)) {
				var _len = ceil(lerp(array_length(_f), array_length(_t), _lrp));
				var res  = array_create(_len);
				
				for( var i = 0; i < _len; i++ ) {
					var rat = i / (_len - 1);
			
					var rf = rat * (array_length(_f) - 1);
					var rt = rat * (array_length(_t) - 1);
					
					var cf = array_get_decimal(_f, rf, true);
					var ct = array_get_decimal(_t, rt, true);
					
					res[i] = merge_color(cf, ct, _lrp);
				}
				
				return res;
			}
			
			return processType(merge_color(_f, _t, _lrp));
		}
		
		if(is_array(_f)) {
			var _vec = array_create(array_length(_f));
			for(var i = 0; i < array_length(_vec); i++) 
				_vec[i] = processType(lerp(_f[i], _t[i], _lrp));
			return _vec;
		}
			
		if(prop.type == VALUE_TYPE.text)
			return processType(_f);
		
		return processType(lerp(_f, _t, _lrp));
	}
	
	static getName = function() { return prop.name + suffix; }
	
	static getValue = function(_time = PROJECT.animator.current_frame) {
		if(prop.type == VALUE_TYPE.trigger) {
			if(ds_list_size(values) == 0) 
				return false;
			
			if(!prop.is_anim)
				return values[| 0].value;
			
			for(var i = 0; i < ds_list_size(values); i++) { //Find trigger
				var _key = values[| i];
				if(_key.time == _time) 
					return _key.value;
			}
			return false;
		}
		
		if(ds_list_size(values) == 0) 
			return processTypeDefault();
		
		if(ds_list_size(values) == 1)
			return processType(values[| 0].value);
		
		if(prop.type == VALUE_TYPE.path)
			return processType(values[| 0].value);
		
		if(!prop.is_anim) 
			return processType(values[| 0].value);
		
		var _time_first = prop.loop_range == -1? values[| 0].time : values[| ds_list_size(values) - 1 - prop.loop_range].time;
		var _time_last  = values[| ds_list_size(values) - 1].time;
		var _time_dura  = _time_last - _time_first;
			
		if(_time > _time_last) { //loop
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
				var prog = PROJECT.animator.frames_total - from.time + _time;
				var totl = PROJECT.animator.frames_total - from.time + to.time;
				
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
			var totl = PROJECT.animator.frames_total - from.time + to.time;
				
			var rat  = prog / totl;
			var _lrp = interpolate(from, to, rat);
				
			return lerpValue(from, to, _lrp);
		}
		
		return processType(values[| ds_list_size(values) - 1].value); //Last frame
	}
	
	static processTypeDefault = function() {
		if(!sep_axis && typeArray(prop.display_type)) return [];
		return 0;
	}
	
	static processType = function(_val) {
		if(!sep_axis && typeArray(prop.display_type) && is_array(_val)) {
			for(var i = 0; i < array_length(_val); i++) 
				_val[i] = processValue(_val[i]);			
			return _val;
		}
		return processValue(_val);
	}
	
	static processValue = function(_val) { 
		if(is_array(_val))     return _val;
		if(is_struct(_val))    return _val;
		if(is_undefined(_val)) return 0;
		
		if(prop.type == VALUE_TYPE.integer && prop.unit.mode == VALUE_UNIT.constant)
			return round(toNumber(_val));
		
		switch(prop.type) {
			case VALUE_TYPE.integer : 
			case VALUE_TYPE.float   : return toNumber(_val);
			case VALUE_TYPE.text    : return string_real(_val);
			case VALUE_TYPE.surface : 
				if(is_string(_val))
					return get_asset(_val);
				return _val;
		}
		
		return _val;
	}
	
	static setKeyTime = function(_key, _time, _replace = true) {
		if(!ds_list_exist(values, _key)) return 0;
		if(!LOADING) PROJECT.modified = true;
		
		_time = max(_time, 0);
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
	
	static setValue = function(_val = 0, _record = true, _time = PROJECT.animator.current_frame, ease_in = 0, ease_out = 0) {
		if(prop.type == VALUE_TYPE.trigger) {
			if(!prop.is_anim) {
				values[| 0] = new valueKey(0, _val, self);
				return true;
			}
			
			for(var i = 0; i < ds_list_size(values); i++) { //Find trigger
				var _key = values[| i];
				if(_key.time == _time)  {
					if(!global.FLAG.keyframe_override) return false;
					
					_key.value = _val;
					return false;
				} else if(_key.time > _time) {
					ds_list_insert(values, i, new valueKey(_time, _val, self));
					return true;
				}
			}
			
			ds_list_add(values, new valueKey(_time, _val, self));
			return true;
		}
		
		if(!prop.is_anim) {
			if(isEqual(values[| 0].value, _val)) 
				return false;
			
			if(_record) recordAction(ACTION_TYPE.var_modify, values[| 0], [ values[| 0].value, "value", prop.name ]);
			values[| 0].value = _val;
			return true;
		}
		
		if(ds_list_size(values) == 0) {
			var k = new valueKey(_time, _val, self, ease_in, ease_out);
			ds_list_add(values, k);
			if(_record) recordAction(ACTION_TYPE.list_insert, values, [ k, ds_list_size(values) - 1, "add " + string(prop.name) + " keyframe" ]);
			return true;
		}
		
		for(var i = 0; i < ds_list_size(values); i++) {
			var _key = values[| i];
			if(_key.time == _time) {
				if(!global.FLAG.keyframe_override) return false;
				
				if(_key.value != _val) {
					if(_record) recordAction(ACTION_TYPE.var_modify, _key, [ _key.value, "value", prop.name ]);
					_key.value = _val;
					return true;
				}
				return false;
			} else if(_key.time > _time) {
				var k = new valueKey(_time, _val, self, ease_in, ease_out);
				ds_list_insert(values, i, k);
				if(_record) recordAction(ACTION_TYPE.list_insert, values, [k, i, "add " + string(prop.name) + " keyframe" ]);
				return true;
			}
		}
		
		var k = new valueKey(_time, _val, self, ease_in, ease_out);
		if(_record) recordAction(ACTION_TYPE.list_insert, values, [ k, ds_list_size(values), "add " + string(prop.name) + " keyframe" ]);
		ds_list_add(values, k);
		return true;
	}
	
	static removeKey = function(key) {
		if(ds_list_size(values) > 1)
			ds_list_remove(values, key);
		else
			prop.is_anim = false;
	}
	
	static serialize = function(scale = false) {
		var _data = [];
		
		for(var i = 0; i < ds_list_size(values); i++) {
			var _value_list = [];
			if(scale)
				_value_list[0] = values[| i].time / (PROJECT.animator.frames_total - 1);
			else
				_value_list[0] = values[| i].time;
			
			var val = values[| i].value;
			
			if(prop.type == VALUE_TYPE.struct)
				_value_list[1] = json_stringify(val);
			else if(is_struct(val))
				_value_list[1] = val.serialize();
			else if(!sep_axis && typeArray(prop.display_type) && is_array(val)) {
				var __v = [];
				for(var j = 0; j < array_length(val); j++) {
					if(is_struct(val[j]) && struct_has(val[j], "serialize"))
						array_push(__v, val[j].serialize()); 
					else 
						array_push(__v, val[j]); 
				}
				_value_list[1] = __v;
			} else
				_value_list[1] = values[| i].value;
			
			_value_list[2] = values[| i].ease_in;
			_value_list[3] = values[| i].ease_out;
			_value_list[4] = values[| i].ease_in_type;
			_value_list[5] = values[| i].ease_out_type;
			_value_list[6] = values[| i].ease_y_lock;
			
			array_push(_data, _value_list);
		}
		
		return _data;
	}
	
	static deserialize = function(_data, scale = false) {
		ds_list_clear(values);
		
		if(prop.type == VALUE_TYPE.gradient && PROJECT.version < 1340 && !CLONING) { //backward compat: Gradient
			var _val = [];
			var value = _data[0][1];
			
			if(is_array(value)) 
			for(var i = 0; i < array_length(value); i++) {
				var _keyframe = value[i];
				var _t = struct_try_get(_keyframe, "time");
				var _v = struct_try_get(_keyframe, "value");
				
				array_push(_val, new gradientKey(_t, _v));
			}
			
			var grad = new gradientObject();
			grad.keys = _val;
			ds_list_add(values, new valueKey(0, grad, self));
			return;
		}
					
		var base = getValue();
		
		for(var i = 0; i < array_length(_data); i++) {
			var _keyframe = _data[i];
			var _time = array_safe_get(_keyframe, 0);
			
			if(scale && _time <= 1)
				_time = round(_time * (PROJECT.animator.frames_total - 1));
			
			var value		  = array_safe_get(_keyframe, 1);
			var ease_in		  = array_safe_get(_keyframe, 2);
			var ease_out	  = array_safe_get(_keyframe, 3);
			var ease_in_type  = array_safe_get(_keyframe, 4);
			var ease_out_type = array_safe_get(_keyframe, 5);
			var ease_y_lock   = array_safe_get(_keyframe, 6, true);
			
			var _val = value;
			
			if(prop.type == VALUE_TYPE.struct)
				_val = json_try_parse(value);
			else if(prop.type == VALUE_TYPE.path && prop.display_type == VALUE_DISPLAY.path_array) {
				for(var j = 0; j < array_length(value); j++)
					_val[j] = value[j];
			} else if(prop.type == VALUE_TYPE.gradient) {
				var grad = new gradientObject();
				_val = grad.deserialize(value);
			} else if(!sep_axis && typeArray(prop.display_type)) {
				_val = [];
				
				if(is_array(value))
				for(var j = 0; j < array_length(value); j++)
					_val[j] = processValue(value[j]);
			} 
			
			//print($"Deserialize {prop.node.name}:{prop.name} = {_val} ");
			var vk = new valueKey(_time, _val, self, ease_in, ease_out);
			vk.ease_in_type  = ease_in_type;
			vk.ease_out_type = ease_out_type;
			vk.ease_y_lock   = ease_y_lock;
			ds_list_add(values, vk);
		}
	}
	
	static cleanUp = function() {
		ds_list_destroy(values);
	}
}