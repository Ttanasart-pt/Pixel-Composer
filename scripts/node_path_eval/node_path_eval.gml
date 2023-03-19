function Node_Path_Sample(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name		= "Sample Path";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Ratio", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	outputs[| 0] = nodeValue("Result", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	function process_data(_output, _data, _output_index, _array_index = 0) {  
		var _path = _data[0];
		var _rat  = _data[1];
		if(_path == noone) 
			return [ 0, 0 ];
		if(!struct_has(_path, "getPointRatio")) 
			return [ 0, 0 ];
		
		return _path.getPointRatio(_rat).toArray();
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(THEME.node_draw_path, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}