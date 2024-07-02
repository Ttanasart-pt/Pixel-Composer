function Node_Zigzag(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Zigzag";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 0.1] })
		.setMappable(6);
		
	inputs[| 2] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 3] = nodeValue("Color 1", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 4] = nodeValue("Color 2", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	inputs[| 5] = nodeValue("Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Solid", "Smooth", "AA" ]);
	
	//////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 6] = nodeValueMap("Amount map", self);
	
	inputs[| 7] = nodeValueMap("Angle map", self);
	
	//////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 8] = nodeValue("Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation)
		.setMappable(7);
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Output",  false], 0,
		["Pattern",	false], 1, 6, 2, 8, 
		["Render",	false], 5, 3, 4, 
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		var pos  = current_data[2];
		var px   = _x + pos[0] * _s;
		var py   = _y + pos[1] * _s;
		var _hov = false;
		
		var  hv  = inputs[| 2].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		var  hv  = inputs[| 8].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	}
	
	static step = function() { #region
		inputs[| 1].mappableStep();
		inputs[| 8].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		var _pos = _data[2];
		
		var _col1 = _data[3];
		var _col2 = _data[4];
		var _bnd  = _data[5];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_zigzag);
			shader_set_f("dimension",   _dim);
			shader_set_f("position",   _pos[0] / _dim[0], _pos[1] / _dim[1]);
			shader_set_f_map("amount", _data[1], _data[6], inputs[| 1]);
			shader_set_f_map("angle",  _data[8], _data[7], inputs[| 8]);
			shader_set_i("blend",      _bnd);
			shader_set_color("col1",   _col1);
			shader_set_color("col2",   _col2);
			
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		return _outSurf;
	}
}