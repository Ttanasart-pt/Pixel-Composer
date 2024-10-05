function Node_Pixel_Cloud(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Pixel Cloud";
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Int("Seed", self, seed_random(6)))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[1].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
		
	newInput(2, nodeValue_Float("Strength", self, 0.1))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 2, 0.01] });
	
	newInput(3, nodeValue_Surface("Strength map", self));
	
	newInput(4, nodeValue_Gradient("Color over lifetime", self, new gradientObject(cola(c_white))))
		.setMappable(9);
	
	newInput(5, nodeValue_Float("Distance", self, 1));
	
	newInput(6, nodeValue_Curve("Alpha over lifetime", self, CURVE_DEF_11));
	
	newInput(7, nodeValue_Float("Random blending", self, 0.1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(8, nodeValue_Bool("Active", self, true));
		active_index = 8;
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(9, nodeValueMap("Gradient map", self));
	
	newInput(10, nodeValueGradientRange("Gradient map range", self, inputs[4]));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	input_display_list = [ 8, 
		["Input",		true],	0, 1,
		["Movement",   false],	5, 2, 3, 
		["Color",		true],	4, 9, 6, 7
	]
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static step = function() {
		inputs[4].mappableStep();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		
		surface_set_shader(_outSurf, sh_pixel_cloud);
			shader_set_f("seed"    , _data[1]);
			shader_set_f("strength", _data[2]);
			shader_set_f("dist"    , _data[5]);
			
			shader_set_i("useMap", is_surface(_data[3]));
			shader_set_surface("strengthMap", _data[3]);
			
			shader_set_gradient(_data[4], _data[9], _data[10], inputs[4]);
			
			shader_set_f("alpha_curve" , _data[6]);
			shader_set_i("curve_amount", array_length(_data[6]));
			shader_set_f("randomAmount", _data[7]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		return _outSurf;
	}
}