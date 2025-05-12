#macro ROTATION_RANDOM_LENGTH 5
#macro ROTATION_RANDOM_DEF_0_360 [ 0, 0, 360, 0, 0 ]

function nodeValue_Rotation_Random(_name, _node, _value, _tooltip = "") { return new __NodeValue_Rotation_Random(_name, _node, _value, _tooltip); }

function __NodeValue_Rotation_Random(_name, _node, _value, _tooltip = "") : __NodeValue_Array(_name, _node, _value, _tooltip, ROTATION_RANDOM_LENGTH) constructor {
	setDisplay(VALUE_DISPLAY.rotation_random);
	def_length = 5;
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) {
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		
		if(!is_array(val))         return [ 0, val, val, 0, 0 ];
		if(array_length(val) == 2) return [ 0, val[0], val[1], 0, 0 ];
		
		return array_verify(val, 5);
	}
}