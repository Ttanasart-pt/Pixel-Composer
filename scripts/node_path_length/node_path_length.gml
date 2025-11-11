function Node_Path_Length(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Path Length";
	setDimension(96, 48);
	
	newInput(0, nodeValue_PathNode( "Path" ));
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.float, 0));
	
	input_display_list = [ 0 ];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) {
		InputDrawOverlay(inputs[0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		var _path = _data[0];
		if(!is_path(_path)) return 0;
		
		return _path.getLength(); 
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		draw_sprite_fit(s_node_path_length, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}