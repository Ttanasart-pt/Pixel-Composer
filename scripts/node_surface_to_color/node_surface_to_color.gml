function Node_Surface_To_Color(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name	= "Surface to Color";
	
	inputs[| 0] = nodeValue("Surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	outputs[| 0] = nodeValue("Color", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, [])
		.setDisplay(VALUE_DISPLAY.palette);
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _surf = _data[0];
		var _pal  = [];
		
		var buff = buffer_from_surface(_surf, false);
		var size = buffer_get_size(buff);
		buffer_seek(buff, buffer_seek_start, 0);
		
		repeat(size) {
			var col = buffer_read(buff, buffer_u8);
			array_push_unique(_pal, col);
		}
		
		return _pal;
	}
}