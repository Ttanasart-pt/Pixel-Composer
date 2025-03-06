function Node_Gap_Contract(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Gap Contract";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Bool("Active", self, true));
		active_index = 1;
	
	newInput(2, nodeValue_Surface("Mask", self));
	
	newInput(3, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	__init_mask_modifier(2); // inputs 4, 5, 
	
	newInput(6, nodeValue_Int("Max Width", self, 8))
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1, 
		["Surfaces", true], 0, 2, 3, 4, 5, 
		["Gap",     false], 6, 
	]
	
	temp_surface = [ noone, noone ];
	
	attribute_surface_depth();
	
	static step = function() {
		__step_mask_modifier();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var surf = _data[0];
		var _itr = _data[6];
		
		var _dim = surface_get_dimension(surf);
		
		for( var i = 0; i < 2; i++ ) temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1]);
		
		var _bg = 0;
		var ang = 0;
		surface_set_shader(temp_surface[1]);
			draw_surface_safe(surf);
		surface_reset_shader();
		
		repeat(_itr * 4) {
			surface_set_shader(temp_surface[_bg], sh_gap_contract);
				shader_set_2("dimension", _dim);
				shader_set_2("direction", [ lengthdir_x(1, ang), lengthdir_y(1, ang) ]);
				
				draw_surface_safe(temp_surface[!_bg]);
			surface_reset_shader();
		
		    ang += 90;
			_bg = !_bg;
		}
		
		surface_set_shader(_outSurf);
			draw_surface_safe(temp_surface[!_bg]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[2], _data[3]);
		
		return _outSurf;
	}
}