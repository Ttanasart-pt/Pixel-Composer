function Node_Surface_From_Buffer(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name	= "Surface from Buffer";
	
	inputs[| 0] = nodeValue("Buffer", self, JUNCTION_CONNECT.input, VALUE_TYPE.buffer, noone)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Surface", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _buff = _data[0];
		var _surf = surface_from_buffer(_buff);
		return _surf;
	}
}