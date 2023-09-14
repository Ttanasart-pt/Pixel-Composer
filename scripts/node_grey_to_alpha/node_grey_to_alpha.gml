function Node_Grey_Alpha(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Grey to Alpha";
	
	shader = sh_grey_alpha;
	uniform_rep	= shader_get_uniform(shader, "replace");
	uniform_col	= shader_get_uniform(shader, "color");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Replace color", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true, "Replace output with solid color.");
	
	inputs[| 2] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 3] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 3;
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 3,
		["Output",	 false], 0, 1, 2, 
	]
	
	attribute_surface_depth();
	
	static step = function() { #region
		var _replace	= inputs[| 1].getValue();	
		inputs[| 2].setVisible(_replace);
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _replace	= inputs[| 1].getValue();
		var _color		= inputs[| 2].getValue();
		
		surface_set_target(_outSurf);
		DRAW_CLEAR
		BLEND_OVERRIDE;
		
		shader_set(shader);
			shader_set_uniform_i(uniform_rep, _replace);
			shader_set_uniform_f_array_safe(uniform_col, colToVec4(_color));
			draw_surface_safe(_data[0], 0, 0);
		shader_reset();
		
		BLEND_NORMAL;
		surface_reset_target();
		
		return _outSurf;
	} #endregion
}