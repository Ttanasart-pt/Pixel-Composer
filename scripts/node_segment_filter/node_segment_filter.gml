function Node_Segment_Filter(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Segment Filter";
	
	setDimension(96, 48);
	
	inputs[| 0] = nodeValue("Segments", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [[]])
		.setDisplay(VALUE_DISPLAY.vector)
		.setArrayDepth(1);
	
	inputs[| 1] = nodeValue("Loop", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	outputs[| 0] = nodeValue("Segments", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [[]])
		.setVisible(false)
		.setArrayDepth(1);
	
	input_display_list = [
		["Segments",	false], 0, 
		["Filter",		false], 1, 
	];
	
	path_preview_surface = noone;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _segments  = getInputData(0);
		
		if(!is_array(_segments) || array_empty(_segments) || !is_array(_segments[0])) return;
		
		if(!is_array(_segments[0][0])) //spreaded single path
			_segments = [ _segments ];
			
		
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
	}
}