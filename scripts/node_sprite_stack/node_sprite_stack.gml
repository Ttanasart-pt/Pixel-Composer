function Node_create_Sprite_Stack(_x, _y) {
	var node = new Node_Sprite_Stack(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Sprite_Stack(_x, _y) : Node(_x, _y) constructor {
	name = "Sprite Stack";
	
	inputs[| 0] = nodeValue(0, "Sequence in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue(1, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2, VALUE_TAG.dimension_2d)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue(2, "Stack amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4);
	inputs[| 3] = nodeValue(3, "Stack shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, -1 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue(4, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	inputs[| 5] = nodeValue(5, "Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 6] = nodeValue(6, "Stack blend", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	
	inputs[| 7] = nodeValue(7, "Alpha end", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1 )
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, .01]);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	static drawOverlay = function(_active, _x, _y, _s, _mx, _my) {
		var pos = inputs[| 4].getValue();
		var px = _x + pos[0] * _s;
		var py = _y + pos[1] * _s;
		
		inputs[| 4].drawOverlay(_active, _x, _y, _s, _mx, _my);
		inputs[| 5].drawOverlay(_active, px, py, _s, _mx, _my);
	}
	
	static update = function() {
		var _in   = inputs[| 0].getValue();
		var _dim  = inputs[| 1].getValue();
		var _amo  = inputs[| 2].getValue();
		var _shf  = inputs[| 3].getValue();
		
		var _pos  = inputs[| 4].getValue();
		var _rot  = inputs[| 5].getValue();
		var _col  = inputs[| 6].getValue();
		var _alp  = inputs[| 7].getValue();
		
		var _outSurf = outputs[| 0].getValue();
		
		if(!is_surface(_outSurf))
			_outSurf = surface_create(surface_valid(_dim[0]), surface_valid(_dim[1]));
		else
			surface_size_to(_outSurf, surface_valid(_dim[0]), surface_valid(_dim[1]));
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
			if(!is_array(_in)) {
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
				}
			} else {
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
	}
}