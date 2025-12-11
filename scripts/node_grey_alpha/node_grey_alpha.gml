function Node_Grey_Alpha(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Grey to Alpha";
	
	newActiveInput(3);
	newInput(0, nodeValue_Surface("Surface In"));
	
	////- Effect
	newInput(4, nodeValue_Curve( "Curve", CURVE_DEF_01 ));
	
	////- Replace
	newInput(2, nodeValue_Color("Color", ca_white));
	newInput(1, nodeValue_Bool("Replace color", true, "Replace output with solid color."));
	// 5
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 3, 0, 
		["Effect",        false    ], 4, 
		["Replace Color", false, 1 ], 2, 
	]
	
	////- Node
	
	attribute_surface_depth();
	
	static step = function() {
		var _replace	= getInputData(1);	
		inputs[2].setVisible(_replace);
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _replace = _data[1];
		var _color   = _data[2];
		var _curve   = _data[4];
		
		surface_set_shader(_outSurf, sh_grey_alpha);
			shader_set_i("replace",      _replace);
			shader_set_c("color",        _color);
			shader_set_curve("modulate", _curve);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		return _outSurf;
	}
}