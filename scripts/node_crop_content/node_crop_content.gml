function Node_Crop_Content(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Crop Content";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Bool("Active", self, true));
	
	newInput(2, nodeValue_Enum_Scroll("Array Sizing", self,  1, [ "Largest, same size", "Independent" ]))
		.setTooltip("Cropping mode for dealing with image array.");
	
	newInput(3, nodeValue_Padding("Padding", self, [ 0, 0, 0, 0 ], "Add padding back after crop."));
	
	newInput(4, nodeValue_Color("Background", self, cola(c_black, 0)));
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Crop distance", self, VALUE_TYPE.integer, [ 0, 0, 0, 0 ]))
		.setDisplay(VALUE_DISPLAY.padding);
	
	newOutput(2, nodeValue_Output("Atlas", self, VALUE_TYPE.atlas, []));
	
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
	
	draw_transforms = [];
	static drawOverlayTransform = function(_node) { return array_safe_get(draw_transforms, preview_index, noone); }
	
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
		_array  &= _arr;
		
		if(!is_array(_inSurf) && !is_surface(_inSurf)) return;
		if( is_array(_inSurf) && array_empty(_inSurf)) return;
		
		if(!_arr) _inSurf = [ _inSurf ];
		var _amo = array_length(_inSurf);
		
		var minx = array_create(_amo,  infinity);
		var miny = array_create(_amo,  infinity);
		var maxx = array_create(_amo, -infinity);
		var maxy = array_create(_amo, -infinity);
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
				minx[0] = min(minx[0], _minx);
				miny[0] = min(miny[0], _miny);
				
				maxx[0] = max(maxx[0], _maxx);
				maxy[0] = max(maxy[0], _maxy);
			}
		}
		
		print(minx, miny);
		
		var res   = [];
		var crop  = [];
		var atlas = [];
		
		for( var i = 0; i < _amo; i++ ) {
			var _surf = _inSurf[i];
			var _ind  = _array == 0? 0 : i;
			
			var resDim  = [maxx[_ind] - minx[_ind] + 1, maxy[_ind] - miny[_ind] + 1];
			resDim[DIMENSION.width]  += _padd[PADDING.left] + _padd[PADDING.right];
			resDim[DIMENSION.height] += _padd[PADDING.top]  + _padd[PADDING.bottom];
			
			res[i]  = surface_create_valid(resDim[DIMENSION.width], resDim[DIMENSION.height], cDep);
			crop[i] = [ surface_get_width_safe(_surf) - maxx[_ind] - 1, miny[_ind], minx[_ind], surface_get_height_safe(_surf) - maxy[_ind] - 1 ];
			
			var _sx = -minx[_ind] + _padd[PADDING.left];
			var _sy = -miny[_ind] + _padd[PADDING.top];
			
			surface_set_shader(res[i], noone);
				draw_surface_safe(_surf, _sx, _sy);
			surface_reset_shader();
			
			atlas[i] = new SurfaceAtlas(res[i], minx[_ind], miny[_ind]);
			draw_transforms[i] = [_sx, _sy, 1, 1, 0];
		}
		
		if(!_arr) {
			res   = res[0];
			crop  = crop[0];
			atlas = atlas[0];
		}
		
		outputs[0].setValue(res);
		outputs[1].setValue(crop);
		outputs[2].setValue(atlas);
	}
}