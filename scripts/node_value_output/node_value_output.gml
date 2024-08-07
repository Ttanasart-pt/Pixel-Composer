function nodeValue_Output(_name, _node, _type, _value, _tooltip = "") { return new NodeValue_Output(_name, _node, _type, _value, _tooltip); }

function NodeValue_Output(_name, _node, _type, _value, _tooltip = "") : NodeValue(_name, _node, JUNCTION_CONNECT.output, _type, _value, _tooltip) constructor {
	
	/////============== GET =============
	
	output_value = 0;
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		return output_value;
	}
	
	static getValueRecursive = function(arr = __curr_get_val, _time = CURRENT_FRAME) {
		arr[@ 0] = output_value;
		arr[@ 1] = self;
	}
	
	static __getAnimValue = function(_time = CURRENT_FRAME) {
		return output_value;
	}
	
	static showValue = function() {
		return output_value;
	}
	
	/////============== SET =============
	
	static setValue = function(val = 0, record = true, time = CURRENT_FRAME, _update = true) { ////Set value
		output_value = val;
		return true;
	}
	
	static setValueDirect = function(val = 0, index = noone, record = true, time = CURRENT_FRAME, _update = true) {
		output_value = val;
		return true;
	}
}