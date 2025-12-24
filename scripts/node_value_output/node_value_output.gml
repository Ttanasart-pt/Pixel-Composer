function nodeValue_Output(_name, _type, _value, _tooltip = "") { return new __NodeValue_Output(_name, self, _type, _value, _tooltip); }
function __NodeValue_Output(_name, _node, _type, _value, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.output, _type, _value, _tooltip) constructor {
	
	parameters.skip_verify = false; skipVerify = function() /*=>*/ { parameters.skip_verify = true; return self; }
	
	index = array_length(node.outputs);
	
	/////============== GET =============
	
	output_value = _value;
	
	static getValue = function(_time = NODE_CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { 
		if(__tempValue != undefined) return __tempValue;
		
		return output_value;
	}
	
	static getValueRecursive = function(arr = __curr_get_val, _time = NODE_CURRENT_FRAME) {
		arr[@ 0] = output_value;
		arr[@ 1] = self;
	}
	
	static __getAnimValue = function() /*=>*/ {return output_value};
	static showValue      = function() /*=>*/ {return output_value};
	
	/////============== SET =============
	
	static setValue = function(val = 0, record = true, time = NODE_CURRENT_FRAME, _update = true) {
		output_value = val;
		
		for( var i = 0, n = array_length(value_to_loop); i < n; i++ )
			value_to_loop[i].updateValue();
		
		return true;
	}
	
	static setValueDirect = function(val = 0, index = noone, record = true, time = NODE_CURRENT_FRAME, _update = true) {
		output_value = val;
		return true;
	}
	
	static shortenDisplay = function() { editWidget.shorted = true; return self; }
}

function __NodeValue_Input_Bypass(_from, _name, _node, _type) : __NodeValue_Output(_name, _node, _type, 0, "") constructor {
	from_junc = _from;
	visible   = false;
	
	static setIndex = function(i) { index = 1000 + i; }
	
	static drawBypass = function(params = {}) {
		if(!from_junc.isVisible()) return;
		
		var _aa	= params.aa;
		var _s	= params.s;
		
		draw_set_color(color_display);
		draw_line_width(from_junc.x * _aa, from_junc.y * _aa, x * _aa, y * _aa, 4 * _aa * _s);
	}
}