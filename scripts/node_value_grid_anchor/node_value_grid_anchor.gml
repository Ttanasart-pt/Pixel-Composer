enum GRID_ANCHOR {
	x,  y,
	tx, ty,
	lx, ly,
	bx, by,
	rx, ry,
	
	size
}

function   nodeValue_Grid_Anchor(_name, _value) { return new __NodeValue_Grid_Anchor(_name, self, _value); }
function __NodeValue_Grid_Anchor(_name, _node, _value) : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.float, _value, "") constructor {
	setDisplay(VALUE_DISPLAY.grid_anchor);
	def_length = GRID_ANCHOR.size;
	
	static valueProcess = function(value, nodeFrom = undefined, applyUnit = true, arrIndex = 0) {
		return applyUnit? unit.apply(value, arrIndex) : value;
	}
	
	static getValue = function(_time = NODE_CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) {
		if(__tempValue != undefined) return __tempValue;
		
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0]; 
		var nod = __curr_get_val[1]; 
		if(!is(nod, NodeValue)) return val;
		
		var _d = array_get_depth(val);
		
		__nod       = nod;
		__applyUnit = applyUnit;
		__arrIndex  = arrIndex;
		
		switch(_d) {
			case 0: return valueProcess(array_create(def_length, val), nod, applyUnit, arrIndex);
			case 1: return valueProcess(array_verify_min_new(val, def_length), nod, applyUnit, arrIndex);
			case 2: return array_map(val, function(v, i) /*=>*/ {return valueProcess(array_verify_min_new(v,def_length), __nod, __applyUnit, __arrIndex)}); 
		}
		
		return val;
	}
}