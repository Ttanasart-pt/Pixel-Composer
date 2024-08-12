function Node_Noise_Cristal(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Cristal Noise";
	shader = sh_noise_cristal;
	
	inputs[1] = nodeValue_Vec2("Position", self, [ 0, 0 ] );
		addShaderProp(SHADER_UNIFORM.float, "position");
		
	inputs[2] = nodeValue_Vec2("Scale", self, [ 1, 1 ] );
		addShaderProp(SHADER_UNIFORM.float, "scale");
		
	inputs[3] = nodeValue_Float("Seed", self, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[3].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
		addShaderProp(SHADER_UNIFORM.float, "seed");
				
	inputs[4] = nodeValue_Int("Iteration", self, 15 );
		addShaderProp(SHADER_UNIFORM.integer, "iteration");
		
	inputs[5] = nodeValue_Color("Color", self, c_white );
		addShaderProp(SHADER_UNIFORM.color, "color");
	
	inputs[6] = nodeValue_Float("Gamma", self, 1 )
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 2, 0.01 ] });
		addShaderProp(SHADER_UNIFORM.float, "gamma");
		
	inputs[7] = nodeValue_Rotation("Phase", self, 0);
		addShaderProp(SHADER_UNIFORM.float, "phase");
		
	input_display_list = [ 3, 
		["Output", 	 true],	0, 
		["Noise",	false],	1, 2, 4, 7, 
		["Render",	false], 5, 6, 
	];
}