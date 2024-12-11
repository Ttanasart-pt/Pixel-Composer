function Node_Tile(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name		= "Tile";
	
	newInput(0, nodeValue_Surface("Base texture", self));
	
	newInput(1, nodeValue_Surface("Border texture", self));
	
	newOutput(0, nodeValue_Output("", self, VALUE_TYPE.surface, noone));
	 
	input_display_list = [ 0 ];
	
	static step = function() {}
	
	static processData = function(_outSurf, _data, _output_index, _array_index = 0) { return _outSurf; }
}