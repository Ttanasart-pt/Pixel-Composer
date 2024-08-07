function Node_MK_Fracture(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Fracture";
	
	inputs[| 0] = nodeValue_Surface("Surface in", self);
	
	inputs[| 1] = nodeValue_Vector("Subdivision", self, [ 4, 4 ]);
	
	inputs[| 2] = nodeValue_Float("Progress", self, 0.5)
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(3);
	
	inputs[| 3] = nodeValueMap("Progress map", self);
	
	inputs[| 4] = nodeValue_Vector("Movement", self, [ 0, 0 ])
		.setMappable(9, true);
	
	inputs[| 5] = nodeValue_Rotation("Rotation", self, 180)
		.setMappable(10);
	
	inputs[| 6] = nodeValue_Float("Scale", self, 0.)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 7] = nodeValue_Float("Alpha", self, 1.)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 8] = nodeValue_Float("Gravity", self, 0.);
	
	inputs[| 9] = nodeValueMap("Movement map", self);
	
	inputs[| 10] = nodeValueMap("Rotation map", self);
	
	inputs[| 11] = nodeValue_Float("Brick Shift", self, 0.)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 12] = nodeValue_Float("Skew", self, 0.)
		.setDisplay(VALUE_DISPLAY.slider, { range : [ -1, 1, 0.01 ] });
	
	inputs[| 13] = nodeValue_Enum_Button("Brick Axis", self,  0, [ "X", "Y" ]);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 0, 
		["Fracture",	false], 1, 2, 13, 11, 12, 
		["Physics",		false], 3, 4, 9, 8, 5, 10, 6, 
		["Render",		false], 7, 
	];
	
	outputs[| 0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		
	} #endregion
	
	static step = function() { #region
		inputs[| 2].mappableStep();
		inputs[| 4].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _surf = _data[0];
		var _dim  = surface_get_dimension(_surf);
		
		surface_set_shader(_outSurf, sh_mk_fracture);
			DRAW_CLEAR
			
			shader_set_f("dimension",    _dim);
			shader_set_f("subdivision",  _data[ 1]);
			shader_set_f_map("progress", _data[ 2], _data[3], inputs[| 2]);
			shader_set_f_map("movement", _data[ 4], _data[9], inputs[| 4]);
			shader_set_f("gravity",      _data[ 8]);
			shader_set_f("rotation",     _data[ 5], _data[10], inputs[| 5]);
			shader_set_f("scale",        _data[ 6]);
			shader_set_f("alpha",        _data[ 7]);
			shader_set_i("axis",		 _data[13]);
			shader_set_f("brickShift",   _data[11]);
			shader_set_f("skew",         _data[12]);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		return _outSurf;
	}
}