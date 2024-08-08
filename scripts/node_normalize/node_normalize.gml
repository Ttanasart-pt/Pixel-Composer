function Node_Normalize(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Normalize";
	
	inputs[0] = nodeValue_Surface("Surface in", self);
	
	inputs[1] = nodeValue_Enum_Button("Mode", self,  0, [ "BW", "RGB" ]);
	
	input_display_list = [ 0, 1 ];
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	temp_surface = [ surface_create(1, 1), surface_create(1, 1), surface_create(1, 1), surface_create(1, 1) ];
	
	static step = function() {
		
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _surf = _data[0];
		var _mode = _data[1];
		
		var _sw  = surface_get_width(_surf);
		var _sh  = surface_get_height(_surf);
		var _itr = ceil(logn(4, _sw * _sh / 1024));
		
		var _sww = ceil(_sw / 2);
		var _shh = ceil(_sh / 2);
		
		for (var i = 0, n = array_length(temp_surface); i < n; i++) 
			temp_surface[i] = surface_verify(temp_surface[i], _sw, _sh);
		
		surface_set_shader(temp_surface[0]);
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		surface_set_shader(temp_surface[1]);
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		surface_clear(temp_surface[2]);
		surface_clear(temp_surface[3]);
		
		var _ind = 1;
		repeat(_itr) {
			surface_resize(temp_surface[(_ind) * 2 + 0], _sww, _shh);
			surface_resize(temp_surface[(_ind) * 2 + 1], _sww, _shh);
			
			shader_set(sh_get_max_downsampled);
			surface_set_target_ext(0, temp_surface[(_ind) * 2 + 0]);
			surface_set_target_ext(1, temp_surface[(_ind) * 2 + 1]);
				shader_set_f("dimension", _sww, _shh);
				shader_set_surface("surfaceMax", temp_surface[(!_ind) * 2 + 0]);
				shader_set_surface("surfaceMin", temp_surface[(!_ind) * 2 + 1]);
				
				draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _sww, _shh);
			surface_reset_target();
			shader_reset();
			
			_sww = ceil(_sww / 2);
			_shh = ceil(_shh / 2);
			
			_ind = !_ind;
		}
		
		var _sMax = temp_surface[(!_ind) * 2 + 0];
		var _sMin = temp_surface[(!_ind) * 2 + 1];
		var _ssw  = surface_get_width(_sMax);
		var _ssh  = surface_get_height(_sMax);
		var _max  = [ 0, 0, 0 ];
		var _min  = [ 1, 1, 1 ];
		var _bMax = buffer_from_surface(_sMax, false);
		var _bMin = buffer_from_surface(_sMin, false);
		
		buffer_seek(_bMax, buffer_seek_start, 0);
		buffer_seek(_bMin, buffer_seek_start, 0);
			repeat(_ssw * _ssh) {
				var _cc = buffer_read(_bMax, buffer_u32);
				_max[0] = max(_max[0], _color_get_red(_cc));
				_max[1] = max(_max[1], _color_get_green(_cc));
				_max[2] = max(_max[2], _color_get_blue(_cc));
				
				var _cc = buffer_read(_bMin, buffer_u32);
				_min[0] = min(_min[0], _color_get_red(_cc));
				_min[1] = min(_min[1], _color_get_green(_cc));
				_min[2] = min(_min[2], _color_get_blue(_cc));
				
			}
		buffer_delete(_bMax);
		buffer_delete(_bMin);
	
		if(_mode == 0) {
			var _bmax = (_max[0] + _max[1] + _max[2]) / 3;
			var _bmin = (_min[0] + _min[1] + _min[2]) / 3;
			
			_max = [ _bmax, _bmax, _bmax ];
			_min = [ _bmin, _bmin, _bmin ];
		}
		
		surface_set_shader(_outSurf, sh_normalize);
			shader_set_f("cMax",       _max);
			shader_set_f("cMin",       _min);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
			
		return _outSurf;
	}
}