function Node_Array_Range(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Array Range";
	setDimension(96, 48);
	
	inputs[| 0] = nodeValue("Start", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.rejectArray();
	
	inputs[| 1] = nodeValue("End", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 10)
		.rejectArray();
	
	inputs[| 2] = nodeValue("Step", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.rejectArray();
	
	outputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, []);
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var st  = _data[0];
		var ed  = _data[1];
		var stp = _data[2];
		var arr = [];
		
		if(st == ed) {
			arr = array_create(stp, st);
		} else if(sign(stp) == sign(ed - st)) {
			var _amo = floor(abs((ed - st) / stp));
			
			for( var i = 0; i < _amo; i++ )
				array_push(arr, st + i * stp);
		}
		
		return arr;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var str = getSingleValue(0);
		var edd = getSingleValue(1);
		var stp = getSingleValue(2);
		var arr = outputs[| 0].getValue();
		
		var str	= "";
		switch(array_length(arr)) {
			case 0 : str = $"[]" break;
			case 1 : 
			case 2 : 
			case 3 : str = $"{arr}" break;
			
			default : str = $"[{arr[0]}, {arr[1]}, ..., {array_safe_get(arr, -1,, ARRAY_OVERFLOW.loop)}]"; break;
		}
		
		var bbox = drawGetBbox(xx, yy, _s);
		draw_text_bbox(bbox, str);
	}
}