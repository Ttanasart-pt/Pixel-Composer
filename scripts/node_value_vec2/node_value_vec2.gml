function nodeValue_Vec2(_name, _node, _value, _data = {}) { return new NodeValue_Vec2(_name, _node, _value, _data); }

function NodeValue_Vec2(_name, _node, _value, _data = {}) : NodeValue(_name, _node, JUNCTION_CONNECT.input, VALUE_TYPE.float, _value, "") constructor {
	setDisplay(VALUE_DISPLAY.vector, _data);
	
	/////============== GET =============
	
	static valueProcess = function(value, nodeFrom = undefined, applyUnit = true, arrIndex = 0) {
		var typeFrom = nodeFrom == undefined? VALUE_TYPE.any : nodeFrom.type;
		
		if(typeFrom == VALUE_TYPE.text) value = toNumber(value);
		if(validator != noone)          value = validator.validate(value);
		
		return applyUnit? unit.apply(value, arrIndex) : value;
	}
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1];
		
		var typ = nod == undefined? VALUE_TYPE.any : nod.type;
		var dis = nod.display_type;
		
		if(typ != VALUE_TYPE.surface) {
			if(!is_array(val))         val = [ val, val ];
			if(array_length(val) != 2) val = [ array_safe_get_fast(val, 0), array_safe_get_fast(val, 1) ];
			
			return valueProcess(val, nod, applyUnit, arrIndex);
		}
		
		// Dimension conversion
		if(is_array(val)) {
			var eqSize = true;
			var sArr = [];
			var _osZ = 0;
			
			for( var i = 0, n = array_length(val); i < n; i++ ) {
				if(!is_surface(val[i])) continue;
				
				var surfSz = surface_get_dimension(val[i]);
				array_push(sArr, surfSz);
				
				if(i && !array_equals(surfSz, _osZ))
					eqSize = false;
				
				_osZ = surfSz;
			}
			
			if(eqSize) return _osZ;
			return sArr;
		} else if (is_surface(val)) 
			return [ surface_get_width_safe(val), surface_get_height_safe(val) ];
		return [ 1, 1 ];
	}
	
	static __getAnimValue = function(_time = CURRENT_FRAME) {
		if(!is_anim) {
			if(sep_axis) return array_create_ext(2, function(i) /*=>*/ {return animators[i].processType(animators[i].values[0].value)});
			return array_empty(animator.values)? 0 : animator.processType(animator.values[0].value);
		}
		
		if(sep_axis) {
			__temp_time = _time;
			return array_create_ext(2, function(i) /*=>*/ {return animators[i].getValue(__temp_time)});
		} 
		
		return animator.getValue(_time);
	}
}