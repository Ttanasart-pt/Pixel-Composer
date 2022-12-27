function Node_Sprite_Stack(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Sprite Stack";
	
	inputs[| 0] = nodeValue(0, "Base shape", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	inputs[| 1] = nodeValue(1, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue(2, "Stack amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4);
	inputs[| 3] = nodeValue(3, "Stack shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 1 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue(4, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(1, index); });
		
	inputs[| 5] = nodeValue(5, "Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 6] = nodeValue(6, "Stack blend", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	
	inputs[| 7] = nodeValue(7, "Alpha end", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1 )
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, .01]);
	
	inputs[| 8] = nodeValue(8, "Move base", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	input_display_list = [
		["Output",	true],	0, 1, 
		["Stack",	false], 2, 3, 8, 4, 5, 
		["Render",  false], 6, 7, 
	];
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var pos = inputs[| 4].getValue();
		var px = _x + pos[0] * _s;
		var py = _y + pos[1] * _s;
		
		inputs[| 4].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		inputs[| 5].drawOverlay(active, px, py, _s, _mx, _my, _snx, _sny);
	}
	
	static process_data = function(_outSurf, _data, _output_index) {
		var _in   = _data[0];
		var _dim  = _data[1];
		var _amo  = _data[2];
		var _shf  = _data[3];
		
		var _pos  = _data[4];
		var _rot  = _data[5];
		var _col  = _data[6];
		var _alp  = _data[7];
		var _mov  = _data[8];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		if(_mov) {
			_pos[0] -= _shf[0] * _amo;
			_pos[1] -= _shf[1] * _amo;
		}
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
			if(is_surface(_in)) {
				var _ww = surface_get_width(_in);
				var _hh = surface_get_width(_in);
				var _po = point_rotate(0, 0, _ww / 2, _hh / 2, _rot);
				var aa  = _alp;
				var aa_delta = (1 - aa) / _amo;
					
				_pos[0] += _shf[0] * _amo;
				_pos[1] += _shf[1] * _amo;
					
				repeat(_amo) {
					draw_surface_ext_safe(_in, _po[0] + _pos[0], _po[1] + _pos[1], 1, 1, _rot, _col, aa);
					_pos[0] -= _shf[0];
					_pos[1] -= _shf[1];
						
					aa += aa_delta;
				}
				draw_surface_ext_safe(_in, _po[0] + _pos[0], _po[1] + _pos[1], 1, 1, _rot, c_white, aa);
			} else if(is_array(_in)) {
				for(var i = 0; i < _amo; i++) {
					var index = clamp(i, 0, array_length(_in) - 1);
					if(is_surface(_in[index])) {
						var _ww = surface_get_width(_in[index]);
						var _hh = surface_get_width(_in[index]);
						var _po = point_rotate(0, 0, _ww / 2, _hh / 2, _rot);
						_po[0]  += _pos[0];
						_po[1]  += _pos[1];
						
						draw_surface_ext_safe(_in[index], _po[0] + _pos[0], _po[1] + _pos[1], 1, 1, _rot, _col, 1);
						_pos[0] += _shf[0];
						_pos[1] += _shf[1];
					}
				}
			}
		surface_reset_target();
		
		return _outSurf;
	}
}