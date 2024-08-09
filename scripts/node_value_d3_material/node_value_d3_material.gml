function nodeValue_D3Material(_name, _node, _value, _tooltip = "") { return new NodeValue_D3Material(_name, _node, _value, _tooltip); }

function NodeValue_D3Material(_name, _node, _value, _tooltip = "") : NodeValue(_name, _node, JUNCTION_CONNECT.input, VALUE_TYPE.d3Material, _value, _tooltip) constructor {
	
	animable = false;
	
	/////============== GET =============
	
	static valueProcess = function(value, nodeFrom = undefined, applyUnit = true, arrIndex = 0) { return value; }
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1];
		
		var typ = nod.type;
		var dis = nod.display_type;
		
		if(nod == self)
			return def_val;
			
		if(typ == VALUE_TYPE.surface) {
			if(!is_array(val)) return def_val.clone(val);
			
			var _val = array_create(array_length(val));
			for( var i = 0, n = array_length(val); i < n; i++ ) 
				_val[i] = def_val.clone(val[i]);
			
			return _val;
		}
		
		return val;
	}
	
	static __getAnimValue = function(_time = CURRENT_FRAME) {
		return array_empty(animator.values)? 0 : animator.values[0].value;
	}
	
	static arrayLength = arrayLengthSimple;
}