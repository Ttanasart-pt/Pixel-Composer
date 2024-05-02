function Node_Array_Range(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Range";
	setDimension(96, 48);
	
	inputs[| 0] = nodeValue("Start", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.rejectArray();
	
	inputs[| 1] = nodeValue("End", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 10)
		.rejectArray();
	
	inputs[| 2] = nodeValue("Step", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.rejectArray();
	
	outputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, []);
	
	static update = function(frame = CURRENT_FRAME) {
		var st  = getInputData(0);
		var ed  = getInputData(1);
		var stp = getInputData(2);
		var arr = [];
		
		if(st == ed) {
			arr = array_create(stp, st);
		} else if(sign(stp) == sign(ed - st)) {
			var _amo = floor(abs((ed - st) / stp));
			
			for( var i = 0; i < _amo; i++ )
				array_push(arr, st + i * stp);
		}
		
		outputs[| 0].setValue(arr);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var str = getInputData(0);
		var edd = getInputData(1);
		var stp = getInputData(2);
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
		var ss	 = string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}