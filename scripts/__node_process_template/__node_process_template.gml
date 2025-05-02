function Node_Process_Template(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name		= "";
	
	newInput(0, nodeValue_Surface("", self));
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0 ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {}
	
	static step = function() {}
	
	static processData = function(_outSurf, _data, _output_index, _array_index = 0) { 
		return _outSurf; 
	}
}