function Node_Array_Get(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name		= "Array Get";
	previewable = false;
	
	w = 96;
	h = 32 + 24;
	min_h = h;
	
	inputs[| 0] = nodeValue(0, "Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue(1, "Index", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setVisible(true, true);
	
	inputs[| 2] = nodeValue(2, "Overflow", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Clamp", "Loop", "Ping Pong"]);
	
	outputs[| 0] = nodeValue(0, "Value", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0);
	
	static update = function() {
		var _arr = inputs[| 0].getValue();
		
		inputs[| 0].type  = VALUE_TYPE.any;
		outputs[| 0].type = VALUE_TYPE.any;
		
		if(!is_array(_arr)) return;
		
		var index = inputs[| 1].getValue();
		var _len = array_length(_arr);
		var _ovf = inputs[| 2].getValue();
		
		switch(_ovf) {
			case 0 :
				index = clamp(index, 0, _len - 1);
				break;
			case 1 :
				index = safe_mod(index, _len);
				if(index < 0) index = _len + index;
				break;
			case 2 :
				var _pplen = (_len - 1) * 2;
				index = safe_mod(abs(index), _pplen);
				if(index >= _len) 
					index = _pplen - index;
				break;
		}
		
		if(inputs[| 0].value_from != noone) {
			inputs[| 0].type  = inputs[| 0].value_from.type;
			outputs[| 0].type = inputs[| 0].type;
		}
		
		outputs[| 0].setValue(_arr[index]);
	}
}