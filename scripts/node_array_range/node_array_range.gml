function Node_Array_Range(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Range";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Start", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.rejectArray();
	
	inputs[| 1] = nodeValue("End", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 10)
		.rejectArray();
	
	inputs[| 2] = nodeValue("Step", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.rejectArray();
	
	outputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, []);
	
	static update = function(frame = CURRENT_FRAME) {
		var st   = getInputData(0);
		var ed   = getInputData(1);
		var step = getInputData(2);
		var arr  = [];
		
		if((step > 0 && st <= ed) || (step < 0 && st >= ed)) {
			for( var i = st; i <= ed; i += step )
				array_push(arr, i);
		}
		
		outputs[| 0].setValue(arr);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
		var str = getInputData(0);
		var edd = getInputData(1);
		var stp = getInputData(2);
		
		var str	= "[" + string(str) + ", " + string(str + stp) + ", ... ," + string(edd) + "]";
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}