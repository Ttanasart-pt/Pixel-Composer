function Node_Array_Range(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "Array range";
	previewable = false;
	
	w = 96;
	min_h = 0;
	
	inputs[| 0] = nodeValue(0, "Start", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	inputs[| 1] = nodeValue(1, "End", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 10);
	inputs[| 2] = nodeValue(2, "Step", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	outputs[| 0] = nodeValue(0, "Array", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, []);
	
	static update = function() {
		var st   = inputs[| 0].getValue();
		var ed   = inputs[| 1].getValue();
		var step = inputs[| 2].getValue();
		var arr  = [];
		
		if((step > 0 && st <= ed) || (step < 0 && st >= ed)) {
			for( var i = st; i <= ed; i += step )
				array_push(arr, i);
		}
		
		outputs[| 0].setValue(arr);
	}
}