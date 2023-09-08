function Node_Sprite_Stack(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Sprite Stack";
	dimension_index = 1;
	
	inputs[| 0] = nodeValue("Base shape", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Stack amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4);
	
	inputs[| 3] = nodeValue("Stack shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 1 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
		
	inputs[| 5] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 6] = nodeValue("Stack blend", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	
	inputs[| 7] = nodeValue("Alpha end", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1, "Alpha value for the last copy." )
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, .01]);
	
	inputs[| 8] = nodeValue("Move base", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Make each copy move the original image." );
	
	inputs[| 9] = nodeValue("Highlight", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "None", "Color", "Inner pixel" ]);
	
	inputs[| 10] = nodeValue("Highlight color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 11] = nodeValue("Highlight alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, .01]);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Output",	true],	0, 1, 
		["Stack",	false], 2, 3, 8, 4, 5, 
		["Render",  false], 6, 7, 9, 10, 11, 
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var pos = inputs[| 4].getValue();
		var px = _x + pos[0] * _s;
		var py = _y + pos[1] * _s;
		
		inputs[| 4].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		inputs[| 5].drawOverlay(active, px, py, _s, _mx, _my, _snx, _sny);
	}
	
	static step = function() {
		var _high = inputs[| 9].getValue();
		
		inputs[| 10].setVisible(_high);
		inputs[| 11].setVisible(_high);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _in  = _data[0];
		var _dim = _data[1];
		var _amo = _data[2];
		var _shf = _data[3];
		
		var _pos = _data[4];
		var _rot = _data[5];
		var _col = _data[6];
		var _alp = _data[7];
		var _mov = _data[8];
		
		var _hig = _data[ 9];
		var _hiC = _data[10];
		var _hiA = _data[11];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		if(_mov) {
			_pos[0] -= _shf[0] * _amo;
			_pos[1] -= _shf[1] * _amo;
		}
		
		surface_set_target(_outSurf);
		DRAW_CLEAR
			if(is_surface(_in)) {
				var _ww = surface_get_width_safe(_in);
				var _hh = surface_get_height_safe(_in);
				var _po = point_rotate(0, 0, _ww / 2, _hh / 2, _rot);
				var aa  = _alp;
				var aa_delta = (1 - aa) / _amo;
					
				_pos[0] += _shf[0] * _amo;
				_pos[1] += _shf[1] * _amo;
					
				for( var i = 0; i < _amo; i++ ) {
					if(_hig && i == _amo - 1) {
						shader_set(sh_replace_color);
						shader_set_i("type", _hig);
						shader_set_f("dimension", _ww, _hh);
						shader_set_f("shift", _shf[0] / _ww, _shf[1] / _hh);
						shader_set_f("angle", degtorad(_rot));
						draw_surface_ext_safe(_in, _po[0] + _pos[0], _po[1] + _pos[1], 1, 1, _rot, _hiC, _hiA);
						shader_reset();
					} else
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
						var _ww = surface_get_width_safe(_in[index]);
						var _hh = surface_get_width_safe(_in[index]);
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