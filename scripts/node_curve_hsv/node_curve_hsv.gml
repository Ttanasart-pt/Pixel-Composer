function Node_Curve_HSV(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "HSV Curve";
	
	newActiveInput(6);
	newInput(7, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- Surfaces
	
	newInput(0, nodeValue_Surface("Surface In"));
	newInput(4, nodeValue_Surface("Mask"));
	newInput(5, nodeValue_Slider("Mix", 1));
	__init_mask_modifier(4); // inputs 8, 9, 
	
	////- Curve
	
	newInput(1, nodeValue_Curve("Hue", CURVE_DEF_01));
	newInput(2, nodeValue_Curve("Saturation", CURVE_DEF_01));
	newInput(3, nodeValue_Curve("Value", CURVE_DEF_01));
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 6, 7, 
		["Surfaces", true],	0, 4, 5, 8, 9, 
		["Curve",	false],	1, 2, 3, 
	];
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index) {	
		var _surf = _data[0];
		var _hcur = _data[1];
		var _scur = _data[2];
		var _vcur = _data[3];
		
		surface_set_shader(_outSurf, sh_curve_hsv);
			shader_set_curve("h", _hcur);
			shader_set_curve("s", _scur);
			shader_set_curve("v", _vcur);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[4], _data[5]);
		_outSurf = channel_apply(_surf, _outSurf, _data[7]);
		
		return _outSurf;
	}
}
