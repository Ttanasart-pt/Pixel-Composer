function Node_Kuwahara(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Kuwahara";
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Bool("Active", self, true));
		active_index = 1;
	
	newInput(2, nodeValue_Int("Radius", self, 2))
		.setValidator(VV_min(1));
	
	newInput(3, nodeValue_Surface("Mask", self));
	
	newInput(4, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(5, nodeValue_Bool("Active", self, true));
		active_index = 5;
	
	newInput(6, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(3); // inputs 7, 8
	
	newInput(9, nodeValue_Enum_Scroll("Types", self, 0, [ "Basic", "Anisotropics", "Generalized" ]));
	
	newInput(10, nodeValue_Float("Alpha", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
		
	newInput(11, nodeValue_Float("Zero crossing", self, 0.58))
		.setDisplay(VALUE_DISPLAY.slider);
		
	newInput(12, nodeValue_Float("Hardness", self, 8))
	
	newInput(13, nodeValue_Float("Sharpness", self, 8))
		
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1, 
		["Surfaces",  true], 0, 3, 4, 7, 8, 
		["Effects",  false], 9, 2, 10, 11, 12, 13, 
	];
	
	temp_surfaces = array_create(4);
	
	attribute_surface_depth();
	
	static step = function() {
		__step_mask_modifier();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _surf = _data[0];
		var _type = _data[9];
		var _dim  = surface_get_dimension(_surf);
		
		inputs[10].setVisible(_type == 1);
		inputs[11].setVisible(_type != 0);
		inputs[12].setVisible(_type != 0);
		inputs[13].setVisible(_type != 0);
		
		switch(_type) {
			case 0 : 
				surface_set_shader(_outSurf, sh_kuwahara);
					shader_set_2("dimension", _dim);
					shader_set_i("radius",      _data[2]);
					
					draw_surface_safe(_surf);
				surface_reset_shader();
				break;
			
			case 1 :
				for( var i = 0; i < 3; i++ ) temp_surfaces[i] = surface_verify(temp_surfaces[i], _dim[0], _dim[1]);
				
				surface_set_shader(temp_surfaces[0], sh_kuwahara_ani_pass1);
					shader_set_2("dimension", _dim);
					
					draw_surface_safe(_surf);
				surface_reset_shader();
				
				surface_set_shader(temp_surfaces[1], sh_kuwahara_ani_pass2);
					shader_set_2("dimension", _dim);
					
					draw_surface_safe(temp_surfaces[0]);
				surface_reset_shader();
				
				surface_set_shader(temp_surfaces[2], sh_kuwahara_ani_pass3);
					shader_set_2("dimension", _dim);
					
					draw_surface_safe(temp_surfaces[1]);
				surface_reset_shader();
				
				surface_set_shader(_outSurf, sh_kuwahara_ani_pass4);
					shader_set_surface("tfm", temp_surfaces[2]);
					shader_set_2("dimension", _dim);
					
					shader_set_f("alpha",        _data[10]);
					shader_set_i("kernelSize",   _data[2]);
					shader_set_f("zeroCrossing", _data[11]);
					shader_set_f("hardness",     _data[12]);
					shader_set_f("sharpness",    _data[13]);

					draw_surface_safe(_surf);
				surface_reset_shader();
				
				break;
			
			case 2 : 
				surface_set_shader(_outSurf, sh_kuwahara_gen);
					shader_set_2("dimension", _dim);
					shader_set_i("kernelSize",   _data[2]);
					shader_set_f("zeroCrossing", _data[11]);
					shader_set_f("hardness",     _data[12]);
					shader_set_f("sharpness",    _data[13]);
					
					draw_surface_safe(_surf);
				surface_reset_shader();
				break;
		}
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_surf, _outSurf, _data[6]);
		
		return _outSurf;
	}
}