function Node_Grey_Alpha(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Grey to Alpha";
	
	newInput(0, nodeValue_Surface("Surface In"));
	
	newInput(1, nodeValue_Bool("Replace color", true, "Replace output with solid color."));
	
	newInput(2, nodeValue_Color("Color", ca_white));
	
	newActiveInput(3);
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 3, 0, 
		["Replace Color", false, 1], 2, 
	]
	
	attribute_surface_depth();
	
	static step = function() {
		var _replace	= getInputData(1);	
		inputs[2].setVisible(_replace);
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _replace	= getInputData(1);
		var _color		= getInputData(2);
		
		surface_set_shader(_outSurf, sh_grey_alpha);
			shader_set_i("replace",   _replace);
			shader_set_color("color", _color);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		return _outSurf;
	}
}