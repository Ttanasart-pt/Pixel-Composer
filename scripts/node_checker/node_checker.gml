function Node_Checker(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Checker";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 2)
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 0.1] })
		.setMappable(6);
	
	inputs[| 2] = nodeValue("Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation)
		.setMappable(7);
	
	inputs[| 3] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 4] = nodeValue("Color 1", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 5] = nodeValue("Color 2", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	//////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 6] = nodeValueMap("Amount map", self);
	
	inputs[| 7] = nodeValueMap("Angle map", self);
	
	//////////////////////////////////////////////////////////////////////////////////
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Output",	true],	0,  
		["Pattern",	false], 1, 6, 2, 7, 3,
		["Render",	false], 4, 5,
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var pos = getInputData(3);
		var px = _x + pos[0] * _s;
		var py = _y + pos[1] * _s;
		
		inputs[| 3].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		inputs[| 2].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny);
	}
	
	static step = function() { #region
		inputs[| 1].mappableStep();
		inputs[| 2].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		var _pos = _data[3];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
			
		surface_set_shader(_outSurf, sh_checkerboard);
			shader_set_f("dimension",   surface_get_width_safe(_outSurf), surface_get_height_safe(_outSurf));
			shader_set_f("position",   _pos[0] / _dim[0], _pos[1] / _dim[1]);
			shader_set_f_map("amount", _data[1], _data[6], inputs[| 1]);
			shader_set_f_map("angle",  _data[2], _data[7], inputs[| 2]);
			shader_set_color("col1",   _data[4]);
			shader_set_color("col2",   _data[5]);
			
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		return _outSurf;
	}
}