function nodeValue_Int(_name, _node, _value, _tooltip = "") { return new __NodeValue_Int(_name, _node, _value, _tooltip); }

function __NodeValue_Int(_name, _node, _value, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.integer, _value, _tooltip) constructor {
	
	/////============== GET =============
	
	static valueProcess = function(value, nodeFrom = undefined, applyUnit = true, arrIndex = 0) {
		if(validator != noone) value = validator.validate(value);
		value = applyUnit? unit.apply(value, arrIndex) : value;
		return is_real(value)? round(value) : value;
	}
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, Node)) return val;
		
		var typ = nod.type;
		var dis = nod.display_type;
		
		if(typ != VALUE_TYPE.surface) {
			if(typ == VALUE_TYPE.text) val = toNumber(val);
			return valueProcess(val, nod, applyUnit);
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
		if(is_anim) return animator.getValue(_time);
		return array_empty(animator.values)? 0 : animator.values[0].value;
	}
	
	static arrayLength = arrayLengthSimple;
}