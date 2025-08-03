function Node_Surface_Is_Empty(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Surface is Empty";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Surface("Surface In"));
	
	newOutput(0, nodeValue_Output("Is Empty", VALUE_TYPE.boolean, false));
	
	input_display_list = [ 0 ];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { }
	
	static step = function() {}
	
	static processData = function(_outSurf, _data, _array_index = 0) {
		var _surf = _data[0];
		var _emp  = surface_is_empty(_surf);
		return _emp; 
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var str  = outputs[0].getValue();
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str? "True" : "False");
	}
}