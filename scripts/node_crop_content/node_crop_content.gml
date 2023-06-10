function Node_Crop_Content(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Crop Content";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 2] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "Cropping mode for dealing with image array.")
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Largest, same size", "Independent" ]);
	
	inputs[| 3] = nodeValue("Padding", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0, 0, 0 ], "Add padding back after crop.")
		.setDisplay(VALUE_DISPLAY.padding);
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 1,
		["Output",	 false], 0, 2, 
		["Padding",	 false], 3, 
	]
	
	attribute_surface_depth();
	
	drag_side = -1;
	drag_mx   = 0;
	drag_my   = 0;
	drag_sv   = 0;
	
	temp_surface = [ surface_create(1, 1), surface_create(1, 1) ];
	
	static findBoundary = function(surface) {
		if(!is_surface(surface)) return [ 0, 0, 0, 0 ];
		
		var _w = surface_get_width(surface);
		var _h = surface_get_height(surface);
		
		var s  = surface_create(_w, _h, surface_r8unorm);
		surface_set_target(s);
			DRAW_CLEAR
			draw_surface_safe(surface, 0, 0);
		surface_reset_target();
		
		var buff = buffer_create(_w * _h, buffer_fast, 1);
		buffer_get_surface(buff, s, 0);
		
		var top = 0;
		for( var i = top; i < _h; i++ )
		for( var j = 0; j < _w; j++ ) {
			var col = buffer_read_at(buff, i * _w + j, buffer_u8);
			if(col > 0) {
				top = i;
				i = _h;
				break;
			}
		}
		
		var bottom = _h;
		for( var i = bottom; i >= top; i-- )
		for( var j = 0; j < _w; j++ ) {
			var col = buffer_read_at(buff, i * _w + j, buffer_u8);
			if(col > 0) {
				bottom = i;
				i = 0;
				break;
			}
		}
		
		var left = 0;
		for( var j = 0; j < _w; j++ ) 
		for( var i = top; i < bottom; i++ ) {
			var col = buffer_read_at(buff, i * _w + j, buffer_u8);
			if(col > 0) {
				left = j;
				j = _w;
				break;
			}
		}
		
		var right = 0;
		for( var j = _w; j >= left; j-- ) 
		for( var i = top; i < bottom; i++ ) {
			var col = buffer_read_at(buff, i * _w + j, buffer_u8);
			if(col > 0) {
				right = j;
				j = 0;
				break;
			}
		}
		
		return [ left, top, right + 1, bottom + 1 ];
	}
	
	static update = function() {
		var _inSurf	= inputs[| 0].getValue();
		var _active	= inputs[| 1].getValue();
		var _array	= inputs[| 2].getValue();
		var _padd	= inputs[| 3].getValue();
		
		var _outSurf = outputs[| 0].getValue();
		surface_array_free(_outSurf);
		
		if(!_active) {			
			_outSurf = surface_array_clone(_inSurf);
			outputs[| 0].setValue(_outSurf);
			
			return;
		}
		
		var _arr = is_array(_inSurf);
		if(!_arr) _inSurf = [ _inSurf ];
			
		var minx = 99999;
		var miny = 99999;
		var maxx = 0;
		var maxy = 0;
		var cDep = attrDepth();
		
		for( var j = 0; j < array_length(_inSurf); j++ ) {
			var _surf = _inSurf[j];
			
			var _dim = [ surface_get_width(_surf), surface_get_height(_surf) ]; 
			var s = surface_create(_dim[0], _dim[1], surface_r8unorm);
			surface_set_target(s);
				DRAW_CLEAR
				draw_surface_safe(_surf, 0, 0);
			surface_reset_target();
			
			var _minx, _miny, _maxx, _maxy;
		
			for( var i = 0; i < array_length(temp_surface); i++ ) {
				temp_surface[i] = surface_verify(temp_surface[i], 1, 1, cDep);
			
				shader_set(sh_find_boundary);
				shader_set_f("dimension", _dim);
				shader_set_i("mode", i);
				if(i) shader_set_f("minn", [ _minx, _miny ]);
				shader_set_surface("texture", s);
				
				surface_set_target(temp_surface[i]);
					DRAW_CLEAR
					BLEND_OVERRIDE;
					draw_surface(s, 0, 0);
					BLEND_NORMAL;
				surface_reset_target();
				shader_reset();
				
				if(i == 0) {
					var minBox = surface_get_pixel_ext(temp_surface[0] , 0, 0);
					_minx = max(0, color_get_red(minBox)  * 256 + color_get_green(minBox));
					_miny = max(0, color_get_blue(minBox) * 256 + color_get_alpha(minBox));
				}
			}
			
			surface_free(s);
			
			var maxBox = surface_get_pixel_ext(temp_surface[1], 0, 0);
			_maxx = color_get_red(maxBox)  * 256 + color_get_green(maxBox) + 1;
			_maxy = color_get_blue(maxBox) * 256 + color_get_alpha(maxBox) + 1;
			
			if(_array == 0) {
				minx = min(minx, _minx);
				miny = min(miny, _miny);
				
				maxx = max(maxx, _maxx);
				maxy = max(maxy, _maxy);
			} else if(_array == 1) {
				minx[j] = _minx;
				miny[j] = _miny;
		
				maxx[j] = _maxx;
				maxy[j] = _maxy;
			}
		}
		
		var res		= [];
		
		for( var i = 0; i < array_length(_inSurf); i++ ) {
			var _surf = _inSurf[i];
			
			if(_array == 0) {
				var resDim  = [maxx - minx, maxy - miny];
				resDim[DIMENSION.width]  += _padd[PADDING.left] + _padd[PADDING.right];
				resDim[DIMENSION.height] += _padd[PADDING.top] + _padd[PADDING.bottom];
				
				res[i] = surface_create_valid(resDim[DIMENSION.width], resDim[DIMENSION.height], cDep);
				
				surface_set_target(res[i]);
					DRAW_CLEAR
					BLEND_OVERRIDE
					draw_surface_safe(_surf, -minx + _padd[PADDING.left], -miny + _padd[PADDING.top]);
					BLEND_NORMAL
				surface_reset_target();
			} else if(_array == 1) {
				var resDim  = [maxx[i] - minx[i], maxy[i] - miny[i]];
				resDim[DIMENSION.width]  += _padd[PADDING.left] + _padd[PADDING.right];
				resDim[DIMENSION.height] += _padd[PADDING.top] + _padd[PADDING.bottom];
				
				res[i] = surface_create_valid(resDim[DIMENSION.width], resDim[DIMENSION.height], cDep);
			
				surface_set_target(res[i]);
					DRAW_CLEAR
					BLEND_OVERRIDE
					draw_surface_safe(_surf, -minx[i] + _padd[PADDING.left], -miny[i] + _padd[PADDING.top]);
					BLEND_NORMAL
				surface_reset_target();
			}
		}
		
		if(!_arr) res = res[0];
		outputs[| 0].setValue(res);
	}
}