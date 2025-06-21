function Node_Path_Flattern(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Path Flattern";
	
	newInput(0, nodeValue_Surface(""));
	
	newOutput(0, nodeValue_Output("", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0 ];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {}
	
	static step = function() {}
	
	static update = function() {}
}
