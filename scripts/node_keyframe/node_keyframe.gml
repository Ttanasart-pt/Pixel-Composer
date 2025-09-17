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
	
	static setTime = function(_time) {
		time  = _time;
		ratio = _time / (TOTAL_FRAMES - 1);
	}
	
	static clone = function(target = noone) {
		var key = new valueKey(time, value, target);
		key.ease_in			= [ ease_in[0],  ease_in[1] ];
		key.ease_out		= [ ease_out[0], ease_out[1] ];
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
			
			if(typeArray(self.anim.prop) != typeArray(anim.prop)) {
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
		array_push(anim.values, key);
		anim.setKeyTime(key, time + shift, removeDup);
		
		return key;
	}
	
	static getDrawIndex = function() {
		if(anim.prop.type == VALUE_TYPE.trigger)
			return 1;
		
		if(drivers.type) 
			return 2;
			
		if(ease_in_type == CURVE_TYPE.cut) 
			return 1;
		
		return 0;
	}
	
	static toString = function() { return $"[Keyframe] {time}: {value}"; }
}

function valueAnimator(_val, _prop, _sep_axis = false) constructor {
	#region ---- main ----
		suffix      = "";
		values	    = [];
		//staticValue = 0;
		
		length   = 1;
		sep_axis = _sep_axis;
		
		index   = 0;      static setIndex = function(i) /*=>*/ { index = i; return self; }
		prop    = _prop;
		y       = 0;
		key_map = array_create(TOTAL_FRAMES);
		key_map_mode = KEYFRAME_END.hold;
		
		animate_frames = [];
		
		if(_prop.type != VALUE_TYPE.trigger) array_push(values, new valueKey(0, _val, self));
	#endregion
	
	////- Getters
	
	__interpolate_curve = [ 0, 0, 0, 0, 0, 1 ];
	static interpolate = function(from, to, rat) {
		if(to.ease_in_type == CURVE_TYPE.linear && from.ease_out_type == CURVE_TYPE.linear) return rat;
		if(rat == 0 || rat == 1) return rat;
		
		var eox = clamp(from.ease_out[0], 0, 0.9);
		var eix = clamp(to.ease_in[0],    0, 0.9);
		var eoy = from.ease_out[1];
		var eiy = to.ease_in[1];
		
		__interpolate_curve[0] = 0;
		__interpolate_curve[1] = eox;
		__interpolate_curve[2] = eoy;
		__interpolate_curve[3] = 1-eix;
		__interpolate_curve[4] = eiy;
		__interpolate_curve[5] = 1;
		
		return eval_curve_segment_x(__interpolate_curve, rat);
	}
	
	static interpolateValue = function(from, to, vfrom, vto, rat) {
		if(rat == 0) return vfrom;
		if(rat == 1) return vto;
		if(to.ease_in_type == CURVE_TYPE.linear && from.ease_out_type == CURVE_TYPE.linear) return lerp(vfrom, vto, rat);
		
		var eox = clamp(from.ease_out[0], 0, 0.9);
		var eix = clamp(to.ease_in[0],    0, 0.9);
		var eoy = from.ease_out[1];
		var eiy = to.ease_in[1];
		
		__interpolate_curve[0] = vfrom;
		__interpolate_curve[1] = eox;
		__interpolate_curve[2] = vfrom + eoy;
		__interpolate_curve[3] = 1-eix;
		__interpolate_curve[4] = vto - (1 - eiy);
		__interpolate_curve[5] = vto;
		
		return eval_curve_segment_x(__interpolate_curve, rat);
	}
	
	static lerpValue = function(from, to, rat) {
		__fr = from;
		__to = to;
		__f = from.value;
		__t = to.value;
		__r = rat;
		
		if(to.ease_in_type    == CURVE_TYPE.cut) return processType(__f);
		if(from.ease_out_type == CURVE_TYPE.cut) return processType(__t);
		if(struct_has(__f, "lerpTo")) return __f.lerpTo(__t, interpolate(from, to, rat))
		
		switch(prop.type) {
			case VALUE_TYPE.float : 
				
				if(prop.display_type == VALUE_DISPLAY.d3quarternion && prop.attributes.angle_display == QUARTERNION_DISPLAY.quarterion)
					return quarternionArraySlerp(__f, __t, interpolate(from, to, rat));
				
				var _af = array_safe_length(__f, -1);
				var _at = array_safe_length(__t, -1);
				
				if(_af ==  0 || _at ==  0) return 0;
				if(_af == -1 || _at == -1) return interpolateValue(__fr, __to, __f, __t, __r);
				
				return array_create_ext(min(_af, _at), function(i) /*=>*/ {return interpolateValue(__fr, __to, __f[i], __t[i], __r)});
				
				// if(_af == _at)             return array_create_ext(_af, (i) => interpolateValue(__fr, __to, __f[i], __t[i], __r));
				
				// if(_af == -1 && _at != -1) return array_create_ext(_at, (i) => interpolateValue(__fr, __to, __f, __t[i], __r));
				// if(_af != -1 && _at == -1) return array_create_ext(_af, (i) => interpolateValue(__fr, __to, __f[i], __t, __r));
				
				// return array_create_ext(max(_af, _at), (i) => interpolateValue(__fr, __to, 
				//                                                     is_array(__f)? array_safe_get_fast(__f, i, 0) : __f, 
				// 			                                        is_array(__t)? array_safe_get_fast(__t, i, 0) : __t, __r));
				
			case VALUE_TYPE.integer : 
				var _af = array_safe_length(__f, -1);
				var _at = array_safe_length(__t, -1);
				
				if(_af ==  0 || _at ==  0) return 0;
				if(_af == -1 || _at == -1) return round(interpolateValue(from, to, __f, __t, rat));
				
				return array_create_ext(min(_af, _at), function(i) /*=>*/ {return round(interpolateValue(__fr, __to, __f[i], __t[i], __r))});
				
				// if(_af == _at)             return array_create_ext(_af, (i) => round(interpolateValue(__fr, __to, __f[i], __t[i], __r)));
				
				// if(_af == -1 && _at != -1) return array_create_ext(_at, (i) => round(interpolateValue(__fr, __to, __f, __t[i], __r)));
				// if(_af != -1 && _at == -1) return array_create_ext(_af, (i) => round(interpolateValue(__fr, __to, __f[i], __t, __r)));
				
				// return array_create_ext(max(_af, _at), (i) => round(interpolateValue(__fr, __to, 
				//                                                      is_array(__f)? array_safe_get_fast(__f, i, 0) : __f, 
				// 			                                         is_array(__t)? array_safe_get_fast(__t, i, 0) : __t, __r)));
			
			case VALUE_TYPE.curve : 
				var _af = array_safe_length(__f, -1);
				var _at = array_safe_length(__t, -1);
				return array_create_ext(min(_af, _at), function(i) /*=>*/ {return interpolateValue(__fr, __to, __f[i], __t[i], __r)});
				
				
			case VALUE_TYPE.color : 
				__lrp = interpolate(from, to, rat);
				
				if(is_array(__f) && is_array(__t)) {
					var _len = ceil(lerp(array_length(__f), array_length(__t), __lrp));
					var res  = array_create(_len);
					
					for( var i = 0; i < _len; i++ ) {
						var _rat = i / (_len - 1);
				
						var rf = _rat * (array_length(__f) - 1);
						var rt = _rat * (array_length(__t) - 1);
						
						var cf = array_get_decimal(__f, rf, true);
						var ct = array_get_decimal(__t, rt, true);
						
						res[i] = merge_color(cf, ct, __lrp);
					}
					return res;
				}
				return processType(merge_color(__f, __t, __lrp));
		}
		
		return processType(__f);
	}
	
	static getName = function() { return prop.name + suffix; }
	
	static getValue = function(_time = CURRENT_FRAME) {
		//if(!prop.is_anim) return staticValue;
		length = array_length(values);
		
		///////////////////////////////////////////////////////////// TRIGGER TYPE /////////////////////////////////////////////////////////////
		
		if(prop.type == VALUE_TYPE.trigger) {
			if(length == 0 || !prop.is_anim) return false;
			
			if(array_length(key_map) != TOTAL_FRAMES) updateKeyMap();
			
			return key_map[_time];
		}
		
		///////////////////////////////////////////////////////////// OPTIMIZATION /////////////////////////////////////////////////////////////
		
		if(length == 0) return processTypeDefault();
		if(length == 1) {
			var _key = values[0];
			
			if(_key.drivers.type && _time >= _key.time)
				return processType(processDriver(_time, _key));
				
			return processType(_key.value);
		}
		
		if(prop.type == VALUE_TYPE.path) return processType(values[0].value);
		if(!prop.is_anim)				 return processType(values[0].value);
		var _len = max(TOTAL_FRAMES, values[length - 1].time);
		if(array_length(key_map) != _len) updateKeyMap();
		
		var _time_first = prop.loop_range == -1? values[0].time : values[length - 1 - prop.loop_range].time;
		var _time_last  = values[length - 1].time;
		var _time_dura  = _time_last - _time_first;
			
		////////////////////////////////////////////////////////////// LOOP TIME ///////////////////////////////////////////////////////////////
		
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
		
		var _keyIndex;
		     if(_time >= _len) _keyIndex = infinity;
		else if(_time <= 0)	   _keyIndex = -1;
		else                   _keyIndex = array_safe_get_fast(key_map, _time);
		
		//////////////////////////////////////////////////////////// BEFORE FIRST //////////////////////////////////////////////////////////////
		
		if(_keyIndex == -1) {
			if(is(prop, __NodeValue_Active)) return false;
			
			if(prop.on_end == KEYFRAME_END.wrap) {
				var from = values[length - 1];
				var to   = values[0];
				
				var fTime = from.time;
				var tTime = to.time;
				
				var prog = TOTAL_FRAMES - fTime + _time;
				var totl = TOTAL_FRAMES - fTime + tTime;
				
				return lerpValue(from, to, prog / totl);
			}
			
			return processType(values[0].value); //First frame
		}
		
		///////////////////////////////////////////////////////////// AFTER LAST ///////////////////////////////////////////////////////////////
		
		if(_keyIndex == infinity) {
			var _lstKey = values[length - 1];
			
			if(_lstKey.drivers.type)
				return processType(processDriver(_time, _lstKey));
			
			if(prop.on_end == KEYFRAME_END.wrap) {
				var from = _lstKey;
				var to   = values[0];
				var prog = _time - from.time;
				var totl = TOTAL_FRAMES - from.time + to.time;
				
				return lerpValue(from, to, prog / totl);
			}
			
			return processType(_lstKey.value); //Last frame
		}
		
		///////////////////////////////////////////////////////////// INBETWEEN ////////////////////////////////////////////////////////////////
		
		var from = values[_keyIndex];
		var to   = values[_keyIndex + 1];
		var rat  = (_time - from.time) / (to.time - from.time);
		
		if(from.drivers.type)
			return processDriver(_time, from, lerpValue(from, to, rat), rat);
			
		return lerpValue(from, to, rat);
		
	}
	
	static processTypeDefault = function() {
		if(!sep_axis && typeArray(prop)) return [];
		return 0;
	}
	
	static processDriver = function(_time, _key, _val = undefined, _intp = 0) {
		
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
	}
	
	static processType = function(_val) {
		INLINE
		
		if(prop.node.project.attributes.strict) return processValue(_val);
		__val    = _val;
		var _res = _val;
		
		if(!sep_axis && typeArray(prop) && is_array(_val))
			_res = array_create_ext(array_length(__val), function(i) /*=>*/ {return processValue(__val[i])});
		else 
			_res = processValue(_val);
		
		return _res;
	}
	
	static processValue = function(_val) {
		INLINE
		
		if(is_array(_val))     return _val;
		if(is_struct(_val))    return _val;
		
		switch(prop.type) {
			case VALUE_TYPE.integer : return is_real(_val) && prop.unit.mode == VALUE_UNIT.constant? round(_val) : _val;
			case VALUE_TYPE.float   : return _val;
			case VALUE_TYPE.text    : return is_string(_val)?  _val : string_real(_val);
			case VALUE_TYPE.color   : return is_real(_val)?    cola(_val) : _val;
			case VALUE_TYPE.surface : return is_string(_val)?  get_asset(_val) : _val;
		}
		
		return _val;
	}
	
	function onUndo() { updateKeyMap(); prop.triggerSetFrom(); }
	
	////- Setters
	
	static setKeyTime = function(_key, _time, _replace = true, record = false) {
		if(!array_exists(values, _key))	    return 0;
		if(_key.time == _time && !_replace)	return 0;
		
		if(!LOADING) prop.node.project.modified = true;
		
		var _prevTime = _key.time;
		_time = max(_time, 0);
		_key.setTime(_time);
		array_remove(values, _key);
		
		if(_replace)
		for( var i = 0; i < array_length(values); i++ ) {
			if(values[i].time != _time) continue;
			
			if(record) recordAction(ACTION_TYPE.custom, function(data) { 
				if(data.undo) insertKey(data.overKey, data.index);
				updateKeyMap();
				
				data.undo = !data.undo;
			}, { overKey : values[i], index : i, undo : true, tooltip : $"Modify '{prop.name}' timeline" }).setRef(prop.node);
			
			values[i] = _key;
			updateKeyMap();
			return 2;
		}
		
		for( var i = 0; i < array_length(values); i++ ) { //insert key before the last key
			if(values[i].time < _time) continue;
			
			if(record) recordAction(ACTION_TYPE.custom, function(data) { 
				var _prevTime = data.key.time; 
				setKeyTime(data.key, data.time, false); 
				
				data.time = _prevTime;
			}, { key : _key, time : _prevTime, tooltip : $"Modify '{prop.name}' timeline" }, onUndo).setRef(prop.node);
			
			array_insert(values, i, _key);
			if(_replace) updateKeyMap();
			return 1;
		}
		
		if(record) recordAction(ACTION_TYPE.custom, function(data) { // insert key after the last key
			var _prevTime = data.key.time; 
			setKeyTime(data.key, data.time, false); 
			
			data.time = _prevTime;
		}, { key : _key, time : _prevTime, tooltip : $"Modify '{prop.name}' timeline" }, onUndo).setRef(prop.node);
			
		array_push(values, _key);
		if(_replace) updateKeyMap();
		return 1;
	}
	
	static setValue = function(_val = 0, _record = true, _time = CURRENT_FRAME, ease_in = 0, ease_out = 0) {
		
		if(prop.type == VALUE_TYPE.trigger) {
			if(!prop.is_anim) {
				values[0] = new valueKey(0, _val, self);
				updateKeyMap();
				return true;
			}
			
			for(var i = 0; i < array_length(values); i++) { //Find trigger
				var _key = values[i];
				if(_key.time == _time)  {
					if(!global.FLAG.keyframe_override) return false;
					
					_key.value = _val;
					return false;
					
				} else if(_key.time > _time) {
					array_insert(values, i, new valueKey(_time, _val, self));
					updateKeyMap();
					return true;
				}
			}
			
			//print($"{_time}: {_val} | Insert last");
			array_push(values, new valueKey(_time, _val, self));
			updateKeyMap();
			return true;
		}
		
		if(!prop.is_anim) {
			if(isEqual(values[0].value, _val)) 
				return false;
			
			if(_record) recordAction_variable_change(values[0], "value", values[0].value, prop.name, onUndo).setRef(prop.node);
			
			values[0].value = _val;
			return true;
		}
		
		if(array_length(values) == 0) { // Should not be called normally
			var k = new valueKey(_time, _val, self, ease_in, ease_out);
			array_push(values, k);
			if(_record) recordAction(ACTION_TYPE.array_insert, values, [ k, array_length(values) - 1, $"Add '{prop.name}'' keyframe" ], onUndo).setRef(prop.node);
			return true;
		}
		
		for(var i = 0; i < array_length(values); i++) {
			var _key = values[i];
			if(_key.time == _time) {
				if(!global.FLAG.keyframe_override) return false;
				
				if(_key.value != _val) {
					if(_record) recordAction_variable_change(_key, "value", _key.value, $"{prop.name}", onUndo).setRef(prop.node);
					_key.value = _val;
					return true;
				}
				return false;
				
			} else if(_key.time > _time) {
				var k = new valueKey(_time, _val, self, ease_in, ease_out);
				array_insert(values, i, k);
				if(_record) recordAction(ACTION_TYPE.array_insert, values, [k, i, $"Add '{prop.name}'' keyframe" ], onUndo).setRef(prop.node);
				updateKeyMap();
				return true;
			}
		}
		
		var k = new valueKey(_time, _val, self, ease_in, ease_out);
		if(_record) recordAction(ACTION_TYPE.array_insert, values, [ k, array_length(values), $"Add '{prop.name}'' keyframe" ], onUndo).setRef(prop.node);
		array_push(values, k);
		updateKeyMap();
		return true;
	}
	
	////- Modify Keys
	
	static updateKeyMap = function() {
		length = array_length(values);
		
		if(!prop.is_anim && !LOADING && !APPENDING) return;
		
		if(array_empty(values)) { 
			array_resize(key_map, TOTAL_FRAMES); 
			return; 
		}
		
		var _len = max(TOTAL_FRAMES, array_last(values).time);
		key_map_mode = prop.on_end;
		
		if(array_length(key_map) != _len)
			array_resize(key_map, _len);
		
		if(prop.type == VALUE_TYPE.trigger) {
			array_fill(key_map, 0, _len, 0);
			for( var i = 0, n = array_length(values); i < n; i++ )
				key_map[values[i].time] = true;
			return;
		} 
		
		if(array_length(values) < 2) {
			array_fill(key_map, 0, _len, 0);
			return;
		}
		
		var _firstKey = values[0].time;
		array_fill(key_map, 0, _firstKey, -1);
		var _keyIndex = _firstKey;
		
		for( var i = 1, n = array_length(values); i < n; i++ ) {
			var _k1 = values[i].time;
			array_fill(key_map, _keyIndex, _k1, i - 1);
			_keyIndex = _k1;
		}
		
		array_fill(key_map, _keyIndex, _len, infinity);
	}
	
	static insertKey = function(_key, _index) { array_insert(values, _index, _key); }
	
	static removeKey = function(key, upd = true) {
		if(array_length(values) > 1) array_remove(values, key);
		else						 prop.is_anim = false;
		if(upd) updateKeyMap();
	}
	
	////- Serialize
	
	static serialize = function(scale = false) {
		var _data = [];
		var _comp = array_length(values) == 1;
		
		for(var i = 0; i < array_length(values); i++) {
			var _value_list = [];
			_value_list[0] = scale? values[i].time / (TOTAL_FRAMES - 1) : values[i].time;
			
			var _v  = values[i];
			var val = _v.value;
			
			if(prop.type == VALUE_TYPE.struct) {
				val = json_stringify(val);
				
			} else if(is_struct(val) && struct_has(val, "serialize")) {
				val = val.serialize();
				
			} else if(!sep_axis && typeArray(prop) && is_array(val)) {
				var __v = [];
				for(var j = 0; j < array_length(val); j++) {
					if(is_struct(val[j]) && struct_has(val[j], "serialize"))
						array_push(__v, val[j].serialize()); 
					else 
						array_push(__v, val[j]); 
				}
				val = __v;
				
			}
			
			_value_list[1] = val;
			_value_list[2] = _v.ease_in;
			_value_list[3] = _v.ease_out;
			_value_list[4] = _v.ease_in_type;
			_value_list[5] = _v.ease_out_type;
			_value_list[6] = _v.ease_y_lock;
			_value_list[7] = _v.drivers.type == DRIVER_TYPE.none? 0 : _v.drivers;
			
			if(_v.drivers.type != DRIVER_TYPE.none) _comp = false;
			if(prop.type == VALUE_TYPE.trigger)     _comp = false;
			
			array_push(_data, _value_list);
		}
		
		if(_comp) return { d: _data[0][1] };
		return _data;
	}
	
	static deserialize = function(_data, scale = false) {
		values = [];
		
		if(is_struct(_data)) _data = [ [ 0, _data.d ] ];
		
		if(prop.type == VALUE_TYPE.gradient && LOADING_VERSION < 1340 && !CLONING) { //backward compat: Gradient
			var _val = [];
			var value = _data[0][1];
			
			if(is_array(value)) 
			for(var i = 0; i < array_length(value); i++) {
				var _keyframe = value[i];
				var _t = _keyframe[$  "time"] ?? 0;
				var _v = _keyframe[$ "value"] ?? 0;
				
				array_push(_val, new gradientKey(_t, _v));
			}
			
			var grad = new gradientObject();
			grad.keys = _val;
			array_push(values, new valueKey(0, grad, self));
			
			updateKeyMap();
			return;
		}
		
		var base = prop.def_val;
		var _typ = prop.type;
		
		for(var i = 0; i < array_length(_data); i++) {
			var _keyframe = _data[i];
			var _time = array_safe_get_fast(_keyframe, 0);
			
			if(scale) _time = round(_time * (TOTAL_FRAMES - 1));
			
			var value		  = array_safe_get_fast(_keyframe, 1);
			var ease_in		  = array_safe_get_fast(_keyframe, 2, [0, 1]);
			var ease_out	  = array_safe_get_fast(_keyframe, 3, [0, 0]);
			var ease_in_type  = array_safe_get_fast(_keyframe, 4, 0);
			var ease_out_type = array_safe_get_fast(_keyframe, 5, 0);
			var ease_y_lock   = array_safe_get_fast(_keyframe, 6, 1);
			var driver        = array_safe_get_fast(_keyframe, 7, 0);
			
			var _val = value;
			
			if(_typ == VALUE_TYPE.struct) {
				_val = json_try_parse(value);
			
			} else if(_typ == VALUE_TYPE.pbBox) {
				_val = new __pbBox().deserialize(value);
				
			} else if(prop.display_type == VALUE_DISPLAY.matrix) {
				_val = new Matrix().deserialize(value);
			
			} else if(_typ == VALUE_TYPE.path && prop.display_type == VALUE_DISPLAY.path_array) {
				for(var j = 0; j < array_length(value); j++)
					_val[j] = value[j];
			
			} else if(_typ == VALUE_TYPE.gradient) {
				_val = new gradientObject().deserialize(value);
			
			} else if(_typ == VALUE_TYPE.d3Material) {
				_val = new __d3dMaterial().deserialize(value);
			
			} else if(_typ == VALUE_TYPE.color) {
				if(is_array(_val)) {
					for( var i = 0, n = array_length(_val); i < n; i++ )
						_val[i] = LOADING_VERSION < 11640 && !is_int64(_val[i])? cola(_val[i]) : int64(_val[i]);
				} else if(is_numeric(_val))
					_val = LOADING_VERSION < 11640 && !is_int64(_val)? cola(_val) : int64(_val);
				else 
					_val = 0;
			
			} else if(_typ == VALUE_TYPE.surface) {
				if(is_struct(_val))
					_val = new dynaDraw().deserialize(_val);
				
			} else if(!sep_axis && typeArray(prop)) {
				_val = [];
				
				if(is_array(value)) {
					for(var j = 0; j < array_length(value); j++)
						_val[j] = processValue(value[j]);
						
				} else if(is_array(base)) {
					for(var j = 0; j < array_length(base); j++)
						_val[j] = processValue(value);
				}
				
				if(prop.type == VALUE_TYPE.curve) {
					var _pd = array_length(_val) % 6;
					
					if(LOADING_VERSION < 1_18_09_1 && _pd == 0)
						array_insert(_val, 0, /**/ 0, 1, 0, 0, 0, 0);
						
					else if(_pd != 0) {
						var _insert = CURVE_PADD - _pd;
						repeat(_insert) array_insert(_val, 2, 0);
					}
					
				}
			} 
			
			// print($"Deserialize {prop.node.name}:{prop.name} = {_val} ");
			var vk = new valueKey(_time, _val, self, ease_in, ease_out);
			vk.ease_in_type  = ease_in_type;
			vk.ease_out_type = ease_out_type;
			vk.ease_y_lock   = ease_y_lock;
			
			if(is_struct(driver)) struct_override(vk.drivers, driver);
			
			array_push(values, vk);
		}
		
		updateKeyMap();
	}
	
	////- Actions
	
	static cleanUp = function() {}
}