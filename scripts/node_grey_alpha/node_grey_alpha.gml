function Node_Grey_Alpha(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Grey to Alpha";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Replace color", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true, "Replace output with solid color.");
	
	inputs[| 2] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 3] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 3;
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 3, 0, 
		["Replace Color", false, 1], 2, 
	]
	
	attribute_surface_depth();
	
	static step = function() { #region
		var _replace	= getInputData(1);	
		inputs[| 2].setVisible(_replace);
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _replace	= getInputData(1);
		var _color		= getInputData(2);
		
		surface_set_shader(_outSurf, sh_grey_alpha);
			shader_set_i("replace",   _replace);
			shader_set_color("color", _color);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
}