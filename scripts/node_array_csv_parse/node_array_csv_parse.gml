function Node_Array_CSV_Parse(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "CSV Parse";
	previewable = false;
	
	w = 96;
	h = 32 + 24;
	min_h = h;
	
	inputs[| 0] = nodeValue("CSV string", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, 0)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Skip line", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	outputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0)
		.setArrayDepth(1);
	
	static update = function(frame = CURRENT_FRAME) {
		var _str = getInputData(0);
		var _skp = getInputData(1);
		
		var _lines = string_splice(_str, "\n");
		var _arr = [];
		
		for( var i = _skp; i < array_length(_lines); i++ )
			array_push(_arr, string_splice(_lines[i], ","));
		
		outputs[| 0].setValue(_arr);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, "CSV");
	}
}