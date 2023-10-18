function Node_Process_Template(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name		= "";
	
	inputs[| 0] = nodeValue("", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	outputs[| 0] = nodeValue("", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, 0);
	
	input_display_list = [ 0 ];
	
	static step = function() {}
	
	static processData = function(_outSurf, _data, _output_index, _array_index = 0) { return _outSurf; }
}