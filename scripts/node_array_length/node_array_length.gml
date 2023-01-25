function Node_Array_Length(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name		= "Array Length";
	previewable = false;
	
	w = 96;
	h = 32 + 24;
	min_h = h;
	
	inputs[| 0] = nodeValue(0, "Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue(0, "Size", self, JUNCTION_CONNECT.output, VALUE_TYPE.integer, 0);
	
	function update() { 
		var _arr = inputs[| 0].getValue();
		
		if(!is_array(_arr) || array_length(_arr) == 0) {
			outputs[| 0].setValue(0);
			return 0;
		}
		
		var nested = false;
		for( var i = 0; i < array_length(_arr); i++ ) {
			nested |= is_array(_arr[i]);
		}
		
		if(!nested) { 
			outputs[| 0].setValue(array_length(_arr));
			return 0;
		}
		
		var len = [];
		for( var i = 0; i < array_length(_arr); i++ ) {
			len[i] = is_array(_arr[i])? array_length(_arr[i]) : 1;
		}
		
		outputs[| 0].setValue(len);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var str	= string(outputs[| 0].getValue());
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}