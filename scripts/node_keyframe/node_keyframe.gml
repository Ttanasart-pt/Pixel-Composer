enum KEY_TYPE    { normal, adder }
enum CURVE_TYPE  { linear, bezier, cut }
enum DRIVER_TYPE { none, linear, wiggle, sine }

function valueKey(_time, _value, _anim = noone, _in = 0, _ot = 0) constructor {
	#region ---- main ----
		time	= _time;
		ratio	= time / (TOTAL_FRAMES - 1);
		value	= _value;
		anim	= _anim;
	
		ease_y_lock = true;
		ease_in	 = is_array(_in)? _in : [_in, 1];
		ease_out = is_array(_ot)? _ot : [_ot, 0];
		
		var _int = anim? anim.prop.key_inter : CURVE_TYPE.linear;
		ease_in_type  = _int;
		ease_out_type = _int;
		
		dopesheet_x = 0;
		
		drivers = {
			seed      : irandom_range(100000, 999999),
			type      : DRIVER_TYPE.none,
			speed     : 1,
			octave    : 2,
			frequency : 4,
			amplitude : 1,
			axis_sync : false,
			phase     : 0,
		};
	#endregion
	
	static setTime = function(time) { #region
		self.time = time;	
		ratio = time / (TOTAL_FRAMES - 1);
	} #endregion
	
	static clone = function(target = noone) { #region
		var key = new valueKey(time, value, target);
		key.ease_in			= ease_in;
		key.ease_out		= ease_out;
		key.ease_in_type	= ease_in_type;
		key.ease_out_type	= ease_out_type;
		
		return key;
	} #endregion
	
	static cloneAnimator = function(shift = 0, anim = noone, removeDup = true) { #region
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
	} #endregion
	
	static getDrawIndex = function() { #region
		if(anim.prop.type == VALUE_TYPE.trigger)
			return 1;
		
		if(drivers.type) 
			return 2;
			
		if(ease_in_type == CURVE_TYPE.cut) 
			return 1;
		
		return 0;
	} #endregion
	
	static toString = function() { return $"[Keyframe] {time}: {value}"; }
}

function valueAnimator(_val, _prop, _sep_axis = false) constructor {
	#region ---- main ----
		suffix   = "";
		values	 = ds_list_create();
		sep_axis = _sep_axis;
		
		index   = 0;
		prop    = _prop;
		y       = 0;
		key_map = array_create(TOTAL_FRAMES);
		key_map_mode = KEYFRAME_END.hold;
		
		animate_frames = [];
		
		if(_prop.type != VALUE_TYPE.trigger)
			ds_list_add(values, new valueKey(0, _val, self));
	#endregion
	
	static refreshAnimation = function() { #region
		animate_frames = array_verify(animate_frames, TOTAL_FRAMES);
		
		var _anim = false;
		var _fr   = noone;
		
		for( var i = 0, n = ds_list_size(values); i < n; i++ ) {
			var _key = values[| i];
			
			if(_fr == noone) {
				array_fill(animate_frames, 0, _key.time, 0);
			} else {
				if(array_equals(_fr.ease_out, [0, 0]) && array_equals(_fr.ease_in, [0, 1]) && isEqual(_fr.value, _key.value))
					array_fill(animate_frames, _fr.time, _key.time, 0);
				else
					array_fill(animate_frames, _fr.time, _key.time, 1);
			}
			
			_fr = _key;
		}
		
		if(_fr) array_fill(animate_frames, _fr.time, TOTAL_FRAMES, 0);
	} #endregion
	
	static updateKeyMap = function() { #region
		if(!prop.is_anim && !LOADING && !APPENDING) return;
		
		if(ds_list_empty(values)) {
			array_resize(key_map, TOTAL_FRAMES);
			return;
		}
		
		var _len = max(TOTAL_FRAMES, values[| ds_list_size(values) - 1].time);
		key_map_mode = prop.on_end;
		
		if(array_length(key_map) != _len)
			array_resize(key_map, _len);
		
		if(ds_list_size(values) < 2) {
			array_fill(key_map, 0, _len, 0);
			return;
		}
		
		var _firstKey = values[| 0].time;
		array_fill(key_map, 0, _firstKey, -1);
		var _keyIndex = _firstKey;
		
		for( var i = 1, n = ds_list_size(values); i < n; i++ ) {
			var _k1 = values[| i].time;
			array_fill(key_map, _keyIndex, _k1, i - 1);
			_keyIndex = _k1;
		}
		
		array_fill(key_map, _keyIndex, _len, 999_999);
	} #endregion
	
	static interpolate = function(from, to, rat) { #region
		if(prop.type == VALUE_TYPE.boolean)
			return 0;
			
		if(to.ease_in_type == CURVE_TYPE.linear && from.ease_out_type == CURVE_TYPE.linear) 
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
	} #endregion
	
	static lerpValue = function(from, to, _lrp) { #region
		var _f = from.value;
		var _t = to.value;
		
		if(is_struct(_f)) {
			if(!struct_has(_f, "lerpTo")) return _f;
			return _f.lerpTo(_t, _lrp);
		}
		
		if(prop.display_type == VALUE_DISPLAY.d3quarternion) {
			if(prop.display_data.angle_display == 0) {
				var _qf = new BBMOD_Quaternion(_f[0], _f[1], _f[2], _f[3]);
				var _qt = new BBMOD_Quaternion(_t[0], _t[1], _t[2], _t[3]);
				var _ql = _qf.Slerp(_qt, _lrp);
				
				return _ql.ToArray();
			} else {
				return [
					lerp(_f[0], _t[0], _lrp),
					lerp(_f[1], _t[1], _lrp),
					lerp(_f[2], _t[2], _lrp),
					0,
				];
			}
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
		
		if(is_array(_f) || is_array(_t)) {
			var _len = max(array_safe_length(_f), array_safe_length(_t));
			var _vec = array_create(_len);
			
			for(var i = 0; i < _len; i++) 
				_vec[i] = processType(
					lerp(
						is_array(_f)? array_safe_get(_f, i, 0) : _f, 
						is_array(_t)? array_safe_get(_t, i, 0) : _t, 
					_lrp)
				);
			return _vec;
		}
			
		if(prop.type == VALUE_TYPE.text)
			return processType(_f);
		
		return processType(lerp(_f, _t, _lrp));
	} #endregion
	
	static getName = function() { return prop.name + suffix; }
	
	static getValue = function(_time = CURRENT_FRAME) { #region
		if(prop.type == VALUE_TYPE.trigger) {
			if(ds_list_size(values) == 0) 
				return false;
			
			if(!prop.is_anim)
				return values[| 0].value;
			
			if(array_length(key_map) != TOTAL_FRAMES) updateKeyMap();
			
			var _keyIndex = key_map[_time];
			
			if(_keyIndex == -1 || _keyIndex == 999_999) 
				return false;
			
			var _key = values[| _keyIndex];
			return _key.time == _time? _key.value : false;
		}
		
		if(ds_list_size(values) == 0) return processTypeDefault();
		if(ds_list_size(values) == 1) {
			var _key = values[| 0];
			
			if(_key.drivers.type && _time >= _key.time)
				return processType(processDriver(_time, _key));
				
			return processType(_key.value);
		}
		
		if(prop.type == VALUE_TYPE.path) return processType(values[| 0].value);
		if(!prop.is_anim)				 return processType(values[| 0].value);
		var _len = max(TOTAL_FRAMES, values[| ds_list_size(values) - 1].time);
		if(array_length(key_map) != _len) updateKeyMap();
		
		var _time_first = prop.loop_range == -1? values[| 0].time : values[| ds_list_size(values) - 1 - prop.loop_range].time;
		var _time_last  = values[| ds_list_size(values) - 1].time;
		var _time_dura  = _time_last - _time_first;
			
		if(_time > _time_last) { #region //loop time
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
		} #endregion
		
		var _keyIndex;
		if(_time >= _len)		_keyIndex = 999_999;
		else if(_time <= 0)		_keyIndex = -1;
		else					_keyIndex = array_safe_get(key_map, _time);
		
		if(_keyIndex == -1) { #region Before first key
			if(prop.on_end == KEYFRAME_END.wrap) {
				var from = values[| ds_list_size(values) - 1];
				var to   = values[| 0];
				
				var fTime = from.time;
				var tTime = to.time;
				
				var prog = TOTAL_FRAMES - fTime + _time;
				var totl = TOTAL_FRAMES - fTime + tTime;
				
				var rat  = prog / totl;
				var _lrp = interpolate(from, to, rat);
				
				return lerpValue(from, to, _lrp);
			}
			
			return processType(values[| 0].value); //First frame
		} #endregion
		
		if(_keyIndex == 999_999) { #region After last key
			var _lstKey = values[| ds_list_size(values) - 1];
			
			if(_lstKey.drivers.type)
				return processType(processDriver(_time, _lstKey));
			
			if(prop.on_end == KEYFRAME_END.wrap) {
				var from = _lstKey;
				var to   = values[| 0];
				var prog = _time - from.time;
				var totl = TOTAL_FRAMES - from.time + to.time;
				
				var rat  = prog / totl;
				var _lrp = interpolate(from, to, rat);
				
				return lerpValue(from, to, _lrp);
			}
			
			return processType(_lstKey.value); //Last frame
		} #endregion
		
		#region In between
			var from = values[| _keyIndex];
			var to   = values[| _keyIndex + 1];
			
			var rat  = (_time - from.time) / (to.time - from.time);
			var _lrp = interpolate(from, to, rat);
			
			if(from.drivers.type)
				return processDriver(_time, from, lerpValue(from, to, _lrp), rat);
			
			return lerpValue(from, to, _lrp);
		#endregion
	} #endregion
	
	static processTypeDefault = function() { #region
		if(!sep_axis && typeArray(prop.display_type)) return [];
		return 0;
	} #endregion
	
	static processDriver = function(_time, _key, _val = undefined, _intp = 0) { #region
		
		static _processDriver = function(val, drivers, _t, _index = 0, _intp = 0) {
			switch(drivers.type) {
				case DRIVER_TYPE.linear : 
					return val + _t * drivers.speed;
					
				case DRIVER_TYPE.wiggle : 
					var w = perlin1D(_t, drivers.seed + _index, drivers.frequency / 10, drivers.octave, -1, 1) * drivers.amplitude;
					return val + w;
					
				case DRIVER_TYPE.sine : 
					var w = sin((drivers.phase * (_index + 1) + _t * drivers.frequency / TOTAL_FRAMES) * pi * 2) * drivers.amplitude;
					return val + w;
			}
			
			return 0;
		}
		
		var _dt  = _time - _key.time;
		    _val = _val == undefined? _key.value : _val;
		var _res = _val;
		
		if(prop.type == VALUE_TYPE.integer || prop.type == VALUE_TYPE.float) {
			if(is_array(_val)) {
				_res = array_create(array_length(_val));
				for( var i = 0, n = array_length(_val); i < n; i++ ) 
					_res[i] = is_numeric(_val[i])? _processDriver(_val[i], _key.drivers, _dt, _key.drivers.axis_sync? 0 : i, _intp) : _val[i];
			} else 
				_res = _processDriver(_val, _key.drivers, _dt, 0, _intp);
		}
		
		return _res;
	} #endregion
	
	static processType = function(_val) { #region
		var _res = _val;
		if(!sep_axis && typeArray(prop.display_type) && is_array(_val)) {
			for(var i = 0; i < array_length(_val); i++) 
				_res[i] = processValue(_val[i]);
		} else 
			_res = processValue(_val);
		
		return _res;
	} #endregion
	
	static processValue = function(_val) { #region
		if(is_array(_val))     return _val;
		if(is_struct(_val))    return _val;
		if(is_undefined(_val)) return 0;
		
		if(prop.type == VALUE_TYPE.integer && prop.unit.mode == VALUE_UNIT.constant)
			return round(_val);
		
		switch(prop.type) {
			case VALUE_TYPE.integer : 
			case VALUE_TYPE.float   : return _val;
			case VALUE_TYPE.text    : return string_real(_val);
			case VALUE_TYPE.color   : return is_real(_val)? cola(_val) : _val;
			case VALUE_TYPE.surface : 
				if(is_string(_val))
					return get_asset(_val);
				return _val;
		}
		
		return _val;
	} #endregion
	
	static insertKey = function(_key, _index) { ds_list_insert(values, _index, _key); }
	
	static setKeyTime = function(_key, _time, _replace = true, record = false) { #region
		if(!ds_list_exist(values, _key))	return 0;
		if(_key.time == _time && !_replace)	return 0;
		
		if(!LOADING) PROJECT.modified = true;
		
		var _prevTime = _key.time;
		_time = max(_time, 0);
		_key.setTime(_time);
		ds_list_remove(values, _key);
		
		if(_replace)
		for( var i = 0; i < ds_list_size(values); i++ ) {
			if(values[| i].time != _time) continue;
			
			if(record) {
				var act = new Action(ACTION_TYPE.custom, function(data) { 
					if(data.undo) insertKey(data.overKey, data.index);
					updateKeyMap();
					
					data.undo = !data.undo;
				}, { overKey : values[| i], index : i, undo : true });
				mergeAction(act);
			}
			
			values[| i] = _key;
			updateKeyMap();
			return 2;
		}
		
		for( var i = 0; i < ds_list_size(values); i++ ) { //insert key before the last key
			if(values[| i].time < _time) continue;
			
			if(record) recordAction(ACTION_TYPE.custom, function(data) { 
				var _prevTime = data.key.time; 
				setKeyTime(data.key, data.time, false); 
				
				data.time = _prevTime;
			}, { key : _key, time : _prevTime });
			
			ds_list_insert(values, i, _key);
			if(_replace) updateKeyMap();
			return 1;
		}
		
		if(record) recordAction(ACTION_TYPE.custom, function(data) { // insert key after the last key
			var _prevTime = data.key.time; 
			setKeyTime(data.key, data.time, false); 
			
			data.time = _prevTime;
		}, { key : _key, time : _prevTime });
			
		ds_list_add(values, _key);
		if(_replace) updateKeyMap();
		return 1;
	} #endregion
	
	static setValue = function(_val = 0, _record = true, _time = CURRENT_FRAME, ease_in = 0, ease_out = 0) { #region
		if(prop.type == VALUE_TYPE.trigger) {
			if(!prop.is_anim) {
				values[| 0] = new valueKey(0, _val, self);
				updateKeyMap();
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
					updateKeyMap();
					return true;
				}
			}
			
			ds_list_add(values, new valueKey(_time, _val, self));
			updateKeyMap();
			return true;
		}
		
		if(!prop.is_anim) {
			if(isEqual(values[| 0].value, _val)) 
				return false;
			
			if(_record) recordAction(ACTION_TYPE.var_modify, values[| 0], [ values[| 0].value, "value", prop.name ]);
			
			values[| 0].value = _val;
			return true;
		}
		
		if(ds_list_size(values) == 0) { // Should not be called normally
			var k = new valueKey(_time, _val, self, ease_in, ease_out);
			ds_list_add(values, k);
			if(_record) recordAction(ACTION_TYPE.list_insert, values, [ k, ds_list_size(values) - 1, $"add {prop.name} keyframe" ], function() { updateKeyMap(); });
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
				if(_record) recordAction(ACTION_TYPE.list_insert, values, [k, i, $"add {prop.name} keyframe" ], function() { updateKeyMap(); });
				updateKeyMap();
				return true;
			}
		}
		
		var k = new valueKey(_time, _val, self, ease_in, ease_out);
		if(_record) recordAction(ACTION_TYPE.list_insert, values, [ k, ds_list_size(values), $"add {prop.name} keyframe" ], function() { updateKeyMap(); });
		ds_list_add(values, k);
		updateKeyMap();
		return true;
	} #endregion
	
	static removeKey = function(key) { #region
		if(ds_list_size(values) > 1)
			ds_list_remove(values, key);
		else
			prop.is_anim = false;
		updateKeyMap();
	} #endregion
	
	static serialize = function(scale = false) { #region
		var _data = [];
		
		for(var i = 0; i < ds_list_size(values); i++) {
			var _value_list = [];
			if(scale)
				_value_list[0] = values[| i].time / (TOTAL_FRAMES - 1);
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
			_value_list[7] = values[| i].drivers;
			
			array_push(_data, _value_list);
		}
		
		return _data;
	} #endregion
	
	static deserialize = function(_data, scale = false) { #region
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
			
			updateKeyMap();
			return;
		}
					
		var base = prop.def_val;
		
		for(var i = 0; i < array_length(_data); i++) {
			var _keyframe = _data[i];
			var _time = array_safe_get(_keyframe, 0);
			
			if(scale && _time <= 1)
				_time = round(_time * (TOTAL_FRAMES - 1));
			
			var value		  = array_safe_get(_keyframe, 1);
			var ease_in		  = array_safe_get(_keyframe, 2);
			var ease_out	  = array_safe_get(_keyframe, 3);
			var ease_in_type  = array_safe_get(_keyframe, 4);
			var ease_out_type = array_safe_get(_keyframe, 5);
			var ease_y_lock   = array_safe_get(_keyframe, 6, true);
			var driver        = array_safe_get(_keyframe, 7, {});
			
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
				
				if(is_array(value)) {
					for(var j = 0; j < array_length(value); j++)
						_val[j] = processValue(value[j]);
				} else if(is_array(base)) {
					for(var j = 0; j < array_length(base); j++)
						_val[j] = processValue(value);
				}
			} 
			
			//print($"Deserialize {prop.node.name}:{prop.name} = {_val} ");
			var vk = new valueKey(_time, _val, self, ease_in, ease_out);
			vk.ease_in_type  = ease_in_type;
			vk.ease_out_type = ease_out_type;
			vk.ease_y_lock   = ease_y_lock;
			struct_override(vk.drivers, driver);
			
			ds_list_add(values, vk);
		}
		
		updateKeyMap();
	} #endregion
	
	static cleanUp = function() { #region
		ds_list_destroy(values);
	} #endregion
}