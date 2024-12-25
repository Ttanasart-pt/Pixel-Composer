function nodeValue_Gradient(_name, _node, _value, _tooltip = "") { return new __NodeValue_Gradient(_name, _node, _value, _tooltip); }

function __NodeValue_Gradient(_name, _node, _value, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.gradient, _value, _tooltip) constructor {
	
	/////============== GET =============
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, Node)) return val;
		
		if(is_instanceof(val, gradientObject)) return val;
		if(nod.type != VALUE_TYPE.color)	   return val;
		
		if(is_array(val)) {
			var amo  = array_length(val);
			var grad = array_create(amo);
			
			for( var i = 0; i < amo; i++ )
				grad[i] = new gradientKey(i / amo, val[i]);
				
			var g = new gradientObject();
			g.keys = grad;
			return g;
		} 
		
		return is_real(val)? new gradientObject(val) : new gradientObject(cola(c_black));
	}
	
	static __getAnimValue = function(_time = CURRENT_FRAME) {
		if(is_anim) return animator.getValue(_time);
		return array_empty(animator.values)? 0 : animator.values[0].value;
	}
	
	static arrayLength = arrayLengthSimple;
	
	static setValueRaw = function(_dat) { 
		if(is(_dat, gradientObject)) {
			setValue(_dat); 
			return;
		}
		
		if(is_struct(_dat)) {
			static_set(_dat, static_get(gradientObject));
			setValue(_dat);
			return;
		}
	}
	
}