function Node_Surface_From_Buffer(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name	= "Surface from Buffer";
	
	newInput(0, nodeValue_Buffer())
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Surface", VALUE_TYPE.surface, noone));
	
	static processData = function(_outSurf, _data, _array_index) {
		var _buff = _data[0];
		var _surf = surface_from_buffer(_buff);
		return _surf;
	}
}