function Node_Cross_Section(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Cross Section";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone );
	
	input_display_list = [
		["Surfaces",	false], 0, 
	];
	
	attribute_surface_depth();
		
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _surf = _data[0];
		
		
		
		return _outSurf;
	}
}