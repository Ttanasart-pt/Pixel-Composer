function Node_Noise_Bubble(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Bubble Noise";
	shader = sh_noise_bubble;
	
	inputs[| 1] = nodeValue("Density", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5 )
		.setDisplay(VALUE_DISPLAY.slider);
		addShaderProp(SHADER_UNIFORM.float, "density");
		
	inputs[| 2] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[| 2].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
		addShaderProp(SHADER_UNIFORM.float, "seed");
				
	inputs[| 3] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0.5, 0.8 ] )
		.setDisplay(VALUE_DISPLAY.slider_range);
		addShaderProp(SHADER_UNIFORM.float, "scale");
				
	inputs[| 4] = nodeValue("Thickness", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 )
		.setDisplay(VALUE_DISPLAY.slider);
		addShaderProp(SHADER_UNIFORM.float, "thickness");
		
	inputs[| 5] = nodeValue("Mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )	
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Line", "Fill" ] );
		addShaderProp(SHADER_UNIFORM.integer, "mode");
		
	inputs[| 6] = nodeValue("Opacity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0., 1. ] )
		.setDisplay(VALUE_DISPLAY.slider_range);
		addShaderProp(SHADER_UNIFORM.float, "alpha");
		
	inputs[| 7] = nodeValue("Blending", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )	
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Max", "Add" ] );
		addShaderProp(SHADER_UNIFORM.integer, "render");
		
	input_display_list = [ 2, 
		["Output", 	 true],	0, 
		["Noise",	false],	1, 3, 
		["Render",	false], 5, 4, 6, 7, 
	];
}