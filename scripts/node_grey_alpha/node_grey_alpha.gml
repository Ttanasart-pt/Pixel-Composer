function Node_Grey_Alpha(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Grey to Alpha";
	
	inputs[0] = nodeValue_Surface("Surface in", self);
	
	inputs[1] = nodeValue_Bool("Replace color", self, true, "Replace output with solid color.");
	
	inputs[2] = nodeValue_Color("Color", self, c_white);
	
	inputs[3] = nodeValue_Bool("Active", self, true);
		active_index = 3;
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 3, 0, 
		["Replace Color", false, 1], 2, 
	]
	
	attribute_surface_depth();
	
	static step = function() { #region
		var _replace	= getInputData(1);	
		inputs[2].setVisible(_replace);
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