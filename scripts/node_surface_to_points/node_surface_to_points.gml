function Node_Surface_To_Points(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Points from Surface";
	setDimension(96, 48);
	setDrawIcon(s_node_surface_to_points);
	
	////- =Surface
	newInput(0, nodeValue_Surface( "Surface" ));
	
	////- =Points
	newInput(1, nodeValue_Vec2( "Range Min", [0,0] )).setUnitSimple();
	newInput(2, nodeValue_Vec2( "Range Max", [1,1] )).setUnitSimple();
	newInput(3, nodeValue_Int( "Max Amount", 0 ));
	
	newOutput(0, nodeValue_Output("Points", VALUE_TYPE.float, [])).setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [
		[ "Surface", false ], 0, 
		[ "Points",  false ], 1, 2, 3, 
	]
	
	////- Node
	
	temp_buffer = undefined;
	
	static getDimension = function() /*=>*/ {return PROJ_SURF};
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _surf = _data[0];
			var _rmin = _data[1];
			var _rmax = _data[2];
			var _maxx = _data[3];
			
			if(!is_surface(_surf)) return _outSurf;
		#endregion
		
		var _bsize = surface_get_byte_size(_surf);
		temp_buffer = buffer_verify(temp_buffer, _bsize, buffer_grow, 1);
		buffer_get_surface(temp_buffer, _surf, 0);
		buffer_to_start(temp_buffer);
		
		var _pixs = surface_get_width(_surf) * surface_get_height(_surf);
		
		var i = 0, _r = 1, _x, _y;
		var btype, offset;
		
		switch(surface_get_format(_surf)) {
			case surface_r16float    : btype = buffer_f16; offset = false; _pixs /= 2; break;
			case surface_r32float    : btype = buffer_f32; offset = false; _pixs /= 2; break;
			
			case surface_rgba8unorm  : btype = buffer_u8;  offset =  true; _r = 255;   break;
			case surface_rgba16float : btype = buffer_f16; offset =  true;             break;
			case surface_rgba32float : btype = buffer_f32; offset =  true;             break;
		}
		
		var _amo = _maxx? min(_maxx, _pixs) : _pixs;
		_outSurf = array_verify(_outSurf, _amo);
		
		repeat(_amo) {
			_x = buffer_read(temp_buffer, btype);
			_y = buffer_read(temp_buffer, btype);
			
			if(offset) {
				buffer_read(temp_buffer, btype);
				buffer_read(temp_buffer, btype);
			}
			
			_x = lerp(_rmin[0], _rmax[0], _x / _r);
			_y = lerp(_rmin[1], _rmax[1], _y / _r);
			
			_outSurf[i++] = [_x, _y];
		}
		
		return _outSurf;
	}
	
	static cleanUp = function() {
		buffer_delete_safe(temp_buffer);
	}
}