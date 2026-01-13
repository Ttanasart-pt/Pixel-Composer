function Node_Color_Separate(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Separate Color";
	
	////- Surfaces
	newInput(0, nodeValue_Surface( "Surface In"       ));
	
	////- Colors
	newInput(1, nodeValue_Bool(    "All Colors", true ));
	newInput(2, nodeValue_Palette( "Colors"           ));
	newInput(3, nodeValue_Bool(    "Match All",  true, "If false, only match pixels with the exact same color."));
	// inputs 4
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "Surfaces",  true ], 0, 
		[ "Colors",   false ], 1, 2, 3, 
	];
	
	////- Node
	
	static extractAll = function(_surf) {
		var ww = surface_get_width_safe(_surf);
		var hh = surface_get_height_safe(_surf);
		
		var c_buffer = buffer_create(ww * hh * 4, buffer_fixed, 4);
		
		buffer_get_surface(c_buffer, _surf, 0);
		buffer_seek(c_buffer, buffer_seek_start, 0);
		
		var amo     = ww * hh;
		var palette = array_create(amo), ind = 0;
		var bm      = 0b11111111 << 24;
		
		for( var i = 0; i < amo; i++ ) {
			var c = buffer_read(c_buffer, buffer_u32);
			if(c & bm == 0) continue;
			palette[ind++] = c;
		}
		
		buffer_delete(c_buffer);
		
		var _len = array_unique_ext(palette, 0, ind);
		array_resize(palette, _len);
		array_sort(palette, __sortHue);
		
		return palette;
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _surf = _data[0];
			var _allc = _data[1];
			var _colr = _data[2];
			var _mata = _data[3];
			
			inputs[2].setVisible(!_allc);
			inputs[3].setVisible(!_allc);
			
			if(!is_surface(_surf)) { surface_array_free(_outSurf); return []; }
		#endregion
		
		var _clist = _colr;
		if(_allc) _clist = extractAll(_surf);
		
		var _dim = surface_get_dimension(_surf);
		_outSurf = surface_array_verify(_outSurf, array_length(_clist));
		
		for( var i = 0, n = array_length(_clist); i < n; i++ ) {
		    _outSurf[i] = surface_verify(_outSurf[i], _dim[0], _dim[1]);
		    
		    surface_set_shader(_outSurf[i], sh_separate_color);
		        shader_set_palette(_clist);
		        shader_set_c("color",    _clist[i]);
		        shader_set_i("matchAll", !_allc && _mata);
		        
		        draw_surface(_surf, 0, 0);
		    surface_reset_shader();
		}
		
		return _outSurf;
	}
}