function Node_Array_Range(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
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
	
	static update = function(frame = ANIMATOR.current_frame) {
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
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
		var str = inputs[| 0].getValue();
		var edd = inputs[| 1].getValue();
		var stp = inputs[| 2].getValue();
		
		var str	= "[" + string(str) + ", " + string(str + stp) + ", ... ," + string(edd) + "]";
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}