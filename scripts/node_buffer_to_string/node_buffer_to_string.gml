function Node_Buffer_to_String(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Buffer to Text";
	
	newInput(0, nodeValue_Buffer(      "Buffer", self)).setVisible(true, true);
	newInput(1, nodeValue_Enum_Scroll( "Format", self, 1, [ "Binary", "Hexadecimal", "ASCII" ]));
	
	newOutput(0, nodeValue_Output("String Out", self, VALUE_TYPE.text, ""));
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _buff = _data[0];
		var _form = _data[1];
		
		var _str = "";
		if(!buffer_exists(_buff)) return _str;
		
		var len = buffer_get_size(_buff);
		buffer_to_start(_buff);
		
		switch(_form) {
			case 0 : repeat(len) { _str += dec_to_bin(buffer_read(_buff, buffer_u8)); } break;
			case 1 : repeat(len) { _str += dec_to_hex(buffer_read(_buff, buffer_u8)); } break;
			case 2 : repeat(len) { _str += chr(buffer_read(_buff, buffer_u8)); }        break;
				
		}
		
		return _str;
	}
}