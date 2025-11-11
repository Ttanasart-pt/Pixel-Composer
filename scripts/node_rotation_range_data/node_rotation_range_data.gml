function Node_Rotation_Range_Data(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Rotation Range";
	color = COLORS.node_blend_number;
	setDimension(96, 48);
	
	////- Rotation
	
	newInput(0, nodeValue_Rotation( "Start",   0 )).setVisible(true, true);
	newInput(1, nodeValue_Rotation( "End", 360 )).setVisible(true, true);
	
	// inputs 2
	
	newOutput(0, nodeValue_Output("Rotation Range", VALUE_TYPE.float, [ 0, 0 ])).setDisplay(VALUE_DISPLAY.rotation_range);
	
	input_display_list = [ 
		["Rotation", false], 0, 1, 
	]
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		var _st = _data[0];
		var _ed = _data[1];
		
		return [ _st, _ed ];
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		draw_sprite_bbox_uniform(s_node_rotation_range_data, 0, bbox);
	}
}