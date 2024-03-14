function Node_Pixel_Cloud(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Pixel Cloud";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, irandom(100000));
		
	inputs[| 2] = nodeValue("Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 2, 0.01] });
	
	inputs[| 3] = nodeValue("Strength map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 4] = nodeValue("Color over lifetime", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject(c_white) )
		.setMappable(9);
	
	inputs[| 5] = nodeValue("Distance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 6] = nodeValue("Alpha over lifetime", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_11);
	
	inputs[| 7] = nodeValue("Random blending", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 8] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 8;
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 9] = nodeValueMap("Gradient map", self);
	
	inputs[| 10] = nodeValueGradientRange("Gradient map range", self, inputs[| 4]);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	input_display_list = [ 8, 
		["Input",		true],	0, 1,
		["Movement",   false],	5, 2, 3, 
		["Color",		true],	4, 9, 6, 7
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static step = function() {
		inputs[| 4].mappableStep();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		
		surface_set_shader(_outSurf, sh_pixel_cloud);
			shader_set_f("seed"    , _data[1]);
			shader_set_f("strength", _data[2]);
			shader_set_f("dist"    , _data[5]);
			
			shader_set_i("useMap", is_surface(_data[3]));
			shader_set_surface("strengthMap", _data[3]);
			
			shader_set_gradient(_data[4], _data[9], _data[10], inputs[| 4]);
			
			shader_set_f("alpha_curve" , _data[6]);
			shader_set_i("curve_amount", array_length(_data[6]));
			shader_set_f("randomAmount", _data[7]);
			
			draw_surface_safe(_data[0], 0, 0);
		surface_reset_shader();
		
		return _outSurf;
	}
}