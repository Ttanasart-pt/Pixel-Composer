function Node_Shape_Map(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Shape Map";
	
	inputs[0] = nodeValue_Surface("Surface in", self);
	
	inputs[1] = nodeValue_Bool("Active", self, true);
		active_index = 1;
	
	inputs[2] = nodeValue_Enum_Scroll("Shape", self,  0, [ new scrollItem("Circle",  s_node_shape_circle, 0), 
												 new scrollItem("Polygon", s_node_shape_misc,   1), ]);
	
	inputs[3] = nodeValue_Vec2("Map Scale", self, [ 4, 1 ]);
	
	inputs[4] = nodeValue_Float("Radius", self, 0.5);
	
	inputs[5] = nodeValue_Int("Sides", self, 4);
	
	inputs[6] = nodeValue_Float("Scale", self, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 2, 0.01 ] });
	
	inputs[7] = nodeValue_Rotation("Angle", self, 0);
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 1, 
		["Surfaces",  true], 0,
		["Shape",    false], 2, 5, 6, 7, 
		["Mapping",  false], 3, 
	];
	
	attribute_surface_depth();
	attribute_oversample();
	attribute_interpolation();
	
	static step = function() { #region
		var _shape = getInputData(2);
		
		inputs[5].setVisible(_shape == 1);
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region	
		var _shape  = _data[2];
		var _scale  = _data[3];
		var _radius = _data[4];
		var _sides  = _data[5];
		var _sca    = _data[6];
		var _rot    = _data[7];
		
		var _dim = surface_get_dimension(_data[0]);
		
		if(_shape == 0) {
			surface_set_shader(_outSurf, sh_shape_map_circle);
			shader_set_interpolation(_data[0]);
				shader_set_2("scale",   _scale);
				shader_set_f("txScale", _sca);
				shader_set_f("angle",   _rot);
				
				draw_surface_safe(_data[0]);
			surface_reset_shader();
			
		} else if(_shape == 1) {
			surface_set_shader(_outSurf, sh_shape_map_polygon);
			shader_set_interpolation(_data[0]);
				shader_set_f("sides",   _sides);
				shader_set_2("scale",   _scale);
				shader_set_f("txScale", _sca);
				shader_set_f("angle",   _rot);
				
				draw_surface_safe(_data[0]);
			surface_reset_shader();
		}
		
		return _outSurf;
	} #endregion
}