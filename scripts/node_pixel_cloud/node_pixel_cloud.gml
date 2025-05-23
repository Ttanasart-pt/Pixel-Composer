function Node_Pixel_Cloud(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Pixel Cloud";
	
	newInput(0, nodeValue_Surface("Surface In"));
	
	newInput(1, nodeValueSeed());
		
	newInput(2, nodeValue_Float("Strength", 0.1))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 2, 0.01] });
	
	newInput(3, nodeValue_Surface("Strength map"));
	
	newInput(4, nodeValue_Gradient("Color over lifetime", new gradientObject(ca_white)))
		.setMappable(9);
	
	newInput(5, nodeValue_Float("Distance", 1));
	
	newInput(6, nodeValue_Curve("Alpha over lifetime", CURVE_DEF_11));
	
	newInput(7, nodeValue_Float("Random blending", 0.1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(8, nodeValue_Bool("Active", true));
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
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index) {
		
		surface_set_shader(_outSurf, sh_pixel_cloud);
			shader_set_f("seed"    , _data[1]);
			shader_set_f("strength", _data[2]);
			shader_set_f("dist"    , _data[5]);
			
			shader_set_i("useMap", is_surface(_data[3]));
			shader_set_surface("strengthMap", _data[3]);
			
			shader_set_gradient(_data[4], _data[9], _data[10], inputs[4]);
			
			shader_set_curve("alpha" , _data[6]);
			shader_set_f("randomAmount", _data[7]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		return _outSurf;
	}
}