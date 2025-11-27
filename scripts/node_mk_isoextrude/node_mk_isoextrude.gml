function Node_MK_Isoextrude(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Isoextrude";
	
	newInput(0, nodeValue_Surface("Surface In"));
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0 ];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { }
	
	static step = function() {}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _surf = _data[0];
			
		#endregion
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			
		surface_reset_target();
		
		return _outSurf; 
	}
}