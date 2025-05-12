function Node_Surface_To_Buffer(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name	= "Buffer from Surface";
	
	newInput(0, nodeValue_Surface("Surface", self));
	
	newOutput(0, nodeValue_Output("Buffer", self, VALUE_TYPE.buffer, noone));
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf = _data[0];
		return buffer_from_surface(_surf);
	}
}