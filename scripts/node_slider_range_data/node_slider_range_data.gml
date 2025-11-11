function Node_Slider_Range_Data(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Slider Range";
	color = COLORS.node_blend_number;
	setDimension(96, 48);
	
	////- Rotation
	
	newInput(0, nodeValue_Float( "Start", 0 ));
	newInput(1, nodeValue_Float( "End", 1 ));
	
	// inputs 2
	
	newOutput(0, nodeValue_Output("Range", VALUE_TYPE.float, [ 0, 0 ])).setDisplay(VALUE_DISPLAY.slider_range);
	
	input_display_list = [ 
		["Range", false], 0, 1, 
	]
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		var _st = _data[0];
		var _ed = _data[1];
		
		return [ _st, _ed ];
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		draw_sprite_bbox_uniform(s_node_slider_range_data, 0, bbox);
	}
}