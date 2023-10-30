function Node_Tile(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name		= "Tile";
	
	inputs[| 0] = nodeValue("Base texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Border texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	outputs[| 0] = nodeValue("", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, 0);
	
	input_display_list = [ 0 ];
	
	static step = function() {}
	
	static processData = function(_outSurf, _data, _output_index, _array_index = 0) { return _outSurf; }
}