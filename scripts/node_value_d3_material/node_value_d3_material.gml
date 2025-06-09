function nodeValue_D3Material(_name, _value = new __d3dMaterial(), _tooltip = "") { return new __NodeValue_D3Material(_name, self, _value, _tooltip); }
function __NodeValue_D3Material(_name, _node, _value, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.d3Material, _value, _tooltip) constructor {
	
	animable = false;
	
	/////============== GET =============
	
	static valueProcess = function(value, nodeFrom = undefined, applyUnit = true, arrIndex = 0) { return value; }
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		
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
		var _anim  = animator;
		var _anims = animators;
		
		return array_empty(_anim.values)? 0 : _anim.values[0].value;
	}
	
	static arrayLength = arrayLengthSimple;
}