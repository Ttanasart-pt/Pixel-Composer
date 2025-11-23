function Node_Corner_Data(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Corner Data";
	color = COLORS.node_blend_number;
	setDrawIcon(s_node_corner_data);
	setDimension(96, 48);
	
	////- Corner
	
	newInput(0, nodeValue_Float( "Top Left", 0 ));
	newInput(1, nodeValue_Float( "Top Right", 0 ));
	newInput(2, nodeValue_Float( "Bottom Left", 0 ));
	newInput(3, nodeValue_Float( "Bottom Right", 0 ));
	
	// inputs 4
	
	newOutput(0, nodeValue_Output("Corner", VALUE_TYPE.float, [ 0, 0, 0, 0 ])).setDisplay(VALUE_DISPLAY.corner);
	
	input_display_list = [ 
		["Corner", false], 0, 1, 2, 3, 
	]
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		var _tl = _data[0];
		var _tr = _data[1];
		var _bl = _data[2];
		var _br = _data[3];
		
		return [ _tl, _tr, _bl, _br ];
	}
	
}