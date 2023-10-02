function Node_Crop_Content(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Crop Content";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 2] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1, "Cropping mode for dealing with image array.")
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
	
	temp_surface = [ surface_create(1, 1, surface_r32float) ];
	
	static update = function() {
		var _inSurf	= getInputData(0);
		var _active	= getInputData(1);
		var _array	= getInputData(2);
		var _padd	= getInputData(3);
		
		var _outSurf = outputs[| 0].getValue();
		surface_array_free(_outSurf);
		
		if(!_active) {			
			_outSurf = surface_array_clone(_inSurf);
			outputs[| 0].setValue(_outSurf);
			
			return;
		}
		
		var _arr = is_array(_inSurf);
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
			var _minx = 0, _miny = 0, _maxx = _dim[0], _maxy = _dim[1];
			temp_surface[0] = surface_verify(temp_surface[0], 1, 1, surface_r32float);
			
			for( var i = 0; i < 4; i++ ) {
				surface_set_target(temp_surface[0]);
					shader_set(sh_find_boundary);
					shader_set_f("dimension", _dim);
					shader_set_surface("texture", _surf);
					
					shader_set_i("mode", i);
					shader_set_f("bbox", [ _minx, _miny, _maxx, _maxy ]);
					
					DRAW_CLEAR
					BLEND_OVERRIDE
					draw_sprite(s_fx_pixel, 0, 0, 0);
					BLEND_NORMAL
					
					shader_reset();
				surface_reset_target();
				
				var px = surface_getpixel(temp_surface[0], 0, 0);
				px = px[0];
				
				switch(i) {
					case 0 : _minx = px; break;
					case 1 : _miny = px; break;
					case 2 : _maxx = px; break;
					case 3 : _maxy = px; break;
				}
			}
			
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
		
		var res	= [];
		
		for( var i = 0, n = _amo; i < n; i++ ) {
			var _surf = _inSurf[i];
			
			if(_array == 0) {
				var resDim  = [maxx - minx + 1, maxy - miny + 1];
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
				var resDim  = [maxx[i] - minx[i] + 1, maxy[i] - miny[i] + 1];
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