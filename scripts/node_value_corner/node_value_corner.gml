function nodeValue_Corner(_name, _value, _tooltip = "") { return new __NodeValue_Corner(_name, self, _value, _tooltip); }

function __NodeValue_Corner(_name, _node, _value, _tooltip = "") : __NodeValue_Array(_name, _node, _value, _tooltip, 4) constructor {
	setDisplay(VALUE_DISPLAY.corner);
	
	////- GET
	
	static valueProcess = function(value, nodeFrom = undefined, applyUnit = true, arrIndex = 0) {
		var typeFrom = nodeFrom == undefined? VALUE_TYPE.any : nodeFrom.type;
		return applyUnit? unit.apply(value, arrIndex) : value;
	}
	
	static getValue = function(_time = NODE_CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { 
		if(__tempValue != undefined) return __tempValue;
		
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		
		var _d = array_get_depth(val);
		
		__nod       = nod;
		__applyUnit = applyUnit;
		__arrIndex  = arrIndex;
		
		if(_d == 0) return valueProcess([val,val,val,val], nod, applyUnit, arrIndex);
		if(_d == 1) return valueProcess(array_verify(val, 4), nod, applyUnit, arrIndex);
		if(_d == 2) return array_map(val, function(v, i) /*=>*/ {return valueProcess(array_verify(v, 4), __nod, __applyUnit, __arrIndex)});
		
		return val;
	}
	
	static __getAnimValue = function(_time = NODE_CURRENT_FRAME) {
		if(sep_axis) var _anims = getAnimators();
		
		if(!getAnim()) {
			if(sep_axis) return [
				_anims[0].processType(_anims[0].values[0].value),
				_anims[1].processType(_anims[1].values[0].value),
				_anims[2].processType(_anims[2].values[0].value),
				_anims[3].processType(_anims[3].values[0].value),
			];
			
			return array_empty(animator.values)? 0 : animator.processType(animator.values[0].value);
		}
		
		if(sep_axis) {
			__temp_time = _time;
			return [
				_anims[0].getValue(__temp_time),
				_anims[1].getValue(__temp_time),
				_anims[2].getValue(__temp_time),
				_anims[3].getValue(__temp_time),
			];
		} 
		
		return animator.getValue(_time);
	}
}