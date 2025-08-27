function Node_Buffer_to_String(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Buffer to Text";
	
	newInput(0, nodeValue_Buffer()).setVisible(true, true);
	newInput(1, nodeValue_Enum_Scroll( "Format", 1, { data: [ "Binary", "Hexadecimal", "ASCII", "Base64" ], update_hover: false }));
	
	newOutput(0, nodeValue_Output("String Out", VALUE_TYPE.text, ""));
	
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

/*[cpp]
	#include <stdio.h>
	#include <string>
	#include <bitset>
	
	using namespace std;
	
	function double buffer_to_string_bin(char* inBuffer, double size, char* outBuffer) {
		int s = (int)size;
		
		for (int i = 0; i < s; i++) {
			std::bitset<8> bits(inBuffer[i]);
			for (int j = 0; j < 8; j++)
				outBuffer[i * 8 + j] = bits[7 - j] ? '1' : '0'; // Reverse order
		}
		outBuffer[s * 8] = '\0';
	
		return s * 8 + 1;
	}
	
	function double buffer_to_string_hex(char* inBuffer, double size, char* outBuffer) {
		int s = (int)size;
	
		for (int i = 0; i < s; i++) {
			#ifdef _WIN32
	        	sprintf_s(outBuffer + i * 2, 3, "%02X", (unsigned char)inBuffer[i]);
			#else
	        	sprintf(outBuffer + i * 2, "%02X", (unsigned char)inBuffer[i]);
			#endif
    	}
		outBuffer[s * 2] = '\0';
		
		return s * 2 + 1; 
	}
	
	function double buffer_to_string_base64(char* inBuffer, double size, char* outBuffer) {
		int s = (int)size;
		const char* base64_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
		int j = 0;
		for (int i = 0; i < s; i += 3) {
			int val = (inBuffer[i] << 16) + ((i + 1 < s ? inBuffer[i + 1] : 0) << 8) + (i + 2 < s ? inBuffer[i + 2] : 0);
			outBuffer[j++] = base64_chars[(val >> 18) & 0x3F];
			outBuffer[j++] = base64_chars[(val >> 12) & 0x3F];
			outBuffer[j++] = (i + 1 < s) ? base64_chars[(val >> 6) & 0x3F] : '=';
			outBuffer[j++] = (i + 2 < s) ? base64_chars[val & 0x3F] : '=';
		}
		outBuffer[j] = '\0'; // Null-terminate the string
		return j; // Return the size of the Base64 string
	}
*/