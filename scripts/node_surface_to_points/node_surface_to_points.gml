function Node_Surface_To_Points(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Points from Surface";
	
	////- =Surface
	newInput(0, nodeValue_Surface( "Surface" ));
	
	////- =Points
	newInput(1, nodeValue_Vec2_Range( "Range", [0,0,1,1] ));
	newInput(2, nodeValue_Int( "Max Amount", 0 ));
	
	newOutput(0, nodeValue_Output("Points", VALUE_TYPE.float, []));
	
	input_display_list = [
		[ "Surface", false ], 0, 
		[ "Points",  false ], 1, 2, 
	]
	
	////- Node
	
	temp_buffer = undefined;
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _surf = _data[0];
			var _rang = _data[1];
			var _maxx = _data[2];
			
			if(!is_surface(_surf)) return _outSurf;
		#endregion
		
		var _bsize = surface_get_byte_size(_surf);
		temp_buffer = buffer_verify(temp_buffer, _bsize, buffer_grow, 1);
		buffer_get_surface(temp_buffer, _surf, 0);
		buffer_to_start(temp_buffer);
		
		var _pixs = surface_get_width(_surf) * surface_get_height(_surf);
		
		_outSurf = array_verify(_outSurf, _amo);
		var i = 0, _x, _y;
		var btype, offset;
		
		switch(surface_get_format(_surf)) {
			case surface_r16float    : btype = buffer_f16; offset = false; _pixs /= 2; break;
			case surface_r32float    : btype = buffer_f32; offset = false; _pixs /= 2; break;
			
			case surface_rgba8unorm  : btype = buffer_u8;  offset =  true; break;
			case surface_rgba16float : btype = buffer_f16; offset =  true; break;
			case surface_rgba32float : btype = buffer_f32; offset =  true; break;
		}
		
		var _amo = _maxx? min(_maxx, _pixs) : _pixs;
		
		repeat(_amo) {
			_x = buffer_read(temp_buffer, btype);
			_y = buffer_read(temp_buffer, btype);
			
			if(offset) {
				buffer_read(temp_buffer, btype);
				buffer_read(temp_buffer, btype);
			}
			
			_x = lerp(_rang[0], _rang[1], _x);
			_y = lerp(_rang[2], _rang[3], _y);
			
			_outSurf[i++] = [_x, _y];
		}
		
		return _outSurf;
	}
	
	static cleanUp = function() {
		buffer_delete_safe(temp_buffer);
	}
}