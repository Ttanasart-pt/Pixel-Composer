function Node_Buffer_to_String(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Buffer to Text";
	
	newInput(0, nodeValue_Buffer(      "Buffer", self)).setVisible(true, true);
	newInput(1, nodeValue_Enum_Scroll( "Format", self, 1, { data: [ "Binary", "Hexadecimal", "ASCII", "Base64" ], update_hover: false }));
	
	newOutput(0, nodeValue_Output("String Out", self, VALUE_TYPE.text, ""));
	
	static processData = function(_outSurf, _data, _array_index) {
		var _buff = _data[0];
		var _form = _data[1];
		
		if(!buffer_exists(_buff)) return "";
		
		var _str = "";
		var  len = buffer_get_size(_buff), i = 0;
		
		switch(_form) {
			case 0 : 
				var _res  = buffer_create(len * 8 + 1, buffer_fixed, 1);
				var _olen = buffer_to_string_bin(buffer_get_address(_buff), len, buffer_get_address(_res));
				
				buffer_to_start(_res);
				_str = buffer_read(_res, buffer_string);
				
				buffer_delete(_res);
				break;
			case 1 : 
				var _res  = buffer_create(len * 2 + 1, buffer_fixed, 1);
				var _olen = buffer_to_string_hex(buffer_get_address(_buff), len, buffer_get_address(_res));
				
				buffer_to_start(_res);
				_str = buffer_read(_res, buffer_string);
				
				buffer_delete(_res);
				break;
			
			case 2 : 
				buffer_to_start(_buff);
				_str = buffer_read(_buff, buffer_string); 
				break;
				
			case 3 : 
				var _res  = buffer_create(len * 4, buffer_fixed, 1);
				var _olen = buffer_to_string_base64(buffer_get_address(_buff), len, buffer_get_address(_res));
				
				buffer_to_start(_res);
				_str = buffer_read(_res, buffer_string);
				
				buffer_delete(_res);
				break;
			
		}
		
		return _str;
	}
}