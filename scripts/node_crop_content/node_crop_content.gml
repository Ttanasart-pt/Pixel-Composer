function Node_Crop_Content(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Crop Content";
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Bool("Active", self, true));
	
	newInput(2, nodeValue_Enum_Scroll("Array Sizing", self,  1, [ "Largest, same size", "Independent" ]))
		.setTooltip("Cropping mode for dealing with image array.");
	
	newInput(3, nodeValue_Padding("Padding", self, [ 0, 0, 0, 0 ], "Add padding back after crop."));
	
	newInput(4, nodeValue_Color("Background", self, cola(c_black, 0)));
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Crop distance", self, VALUE_TYPE.integer, [ 0, 0, 0, 0 ]))
		.setDisplay(VALUE_DISPLAY.padding);
	
	input_display_list = [ 1,
		["Surfaces", false], 0, 2, 4, 
		["Padding",	 false], 3, 
	]
	
	attribute_surface_depth();
	
	drag_side = -1;
	drag_mx   = 0;
	drag_my   = 0;
	drag_sv   = 0;
	
	temp_surface = [ 0, 0 ];
	
	static update = function() {
		var _inSurf	= getInputData(0);
		var _active	= getInputData(1);
		var _array	= getInputData(2);
		var _padd	= getInputData(3);
		var _bg 	= getInputData(4);
		
		var _outSurf = outputs[0].getValue();
		surface_array_free(_outSurf);
		
		if(!_active) {			
			_outSurf = surface_array_clone(_inSurf);
			outputs[0].setValue(_outSurf);
			return;
		}
		
		var _arr = is_array(_inSurf);
		_array &= _arr;
		
		if(!is_array(_inSurf) && !is_surface(_inSurf)) return;
		if( is_array(_inSurf) && array_empty(_inSurf)) return;
		
		if(!_arr) _inSurf = [ _inSurf ];
		var _amo = array_length(_inSurf);
		
		var minx = _array? array_create(_amo) : 999999;
		var miny = _array? array_create(_amo) : 999999;
		var maxx = _array? array_create(_amo) : 0;
		var maxy = _array? array_create(_amo) : 0;
		var cDep = attrDepth();
		
		for( var j = 0; j < _amo; j++ ) {
			var _surf = _inSurf[j];
			
			var _dim  = [ surface_get_width_safe(_surf), surface_get_height_safe(_surf) ]; 
			var _minx = 0, _miny = 0, _maxx = _dim[0] - 1, _maxy = _dim[1] - 1;
			
			temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1], surface_r8unorm);
			temp_surface[1] = surface_verify(temp_surface[1], _dim[0], _dim[1], surface_r8unorm);
			
			surface_set_shader(temp_surface[0], sh_find_boundary_stretch_x);
				shader_set_color("background", _bg);
				shader_set_f("dimension", _dim);
				
				draw_surface_safe(_surf);
			surface_reset_shader();
			
			surface_set_shader(temp_surface[1], sh_find_boundary_stretch_y);
				shader_set_color("background", _bg);
				shader_set_f("dimension", _dim);
				
				draw_surface_safe(_surf);
			surface_reset_shader();
			
			var _buff0 = buffer_from_surface(temp_surface[0], false);
			var _buff1 = buffer_from_surface(temp_surface[1], false);
			
			for( ; _minx < _dim[0]; _minx++ ) if(buffer_read_at(_buff0, _minx, buffer_u8) > 0) break;
			for( ; _maxx >= 0; _maxx-- )      if(buffer_read_at(_buff0, _maxx, buffer_u8) > 0) break;
			for( ; _miny < _dim[1]; _miny++ ) if(buffer_read_at(_buff1, _dim[0] * _miny, buffer_u8) > 0) break;
			for( ; _maxy >= 0; _maxy-- )      if(buffer_read_at(_buff1, _dim[0] * _maxy, buffer_u8) > 0) break;
			
			buffer_delete(_buff0);
			buffer_delete(_buff1);
			
			if(_array) {
				minx[j] = _minx;
				miny[j] = _miny;
		
				maxx[j] = _maxx;
				maxy[j] = _maxy;
			} else {
				minx = min(minx, _minx);
				miny = min(miny, _miny);
				
				maxx = max(maxx, _maxx);
				maxy = max(maxy, _maxy);
			}
		}
		
		var res  = [];
		var crop = [];
		
		for( var i = 0, n = _amo; i < n; i++ ) {
			var _surf = _inSurf[i];
			
			if(_array == 0) {
				var resDim  = [maxx - minx + 1, maxy - miny + 1];
				resDim[DIMENSION.width]  += _padd[PADDING.left] + _padd[PADDING.right];
				resDim[DIMENSION.height] += _padd[PADDING.top] + _padd[PADDING.bottom];
				
				res[i]  = surface_create_valid(resDim[DIMENSION.width], resDim[DIMENSION.height], cDep);
				crop[i] = [ surface_get_width_safe(_surf) - maxx - 1, miny, minx, surface_get_height_safe(_surf) - maxy - 1 ];
				
				surface_set_shader(res[i], noone);
					draw_surface_safe(_surf, -minx + _padd[PADDING.left], -miny + _padd[PADDING.top]);
				surface_reset_shader();
				
			} else if(_array == 1) {
				var resDim  = [maxx[i] - minx[i] + 1, maxy[i] - miny[i] + 1];
				resDim[DIMENSION.width]  += _padd[PADDING.left] + _padd[PADDING.right];
				resDim[DIMENSION.height] += _padd[PADDING.top] + _padd[PADDING.bottom];
				
				res[i] = surface_create_valid(resDim[DIMENSION.width], resDim[DIMENSION.height], cDep);
				crop[i] = [ surface_get_width_safe(_surf) - maxx - 1, miny, minx, surface_get_height_safe(_surf) - maxy - 1 ];
				
				surface_set_shader(res[i], noone);
					draw_surface_safe(_surf, -minx[i] + _padd[PADDING.left], -miny[i] + _padd[PADDING.top]);
				surface_reset_shader();
			}
		}
		
		if(!_arr) {
			res  = res[0];
			crop = crop[0];
		}
		
		outputs[0].setValue(res);
		outputs[1].setValue(crop);
	}
}