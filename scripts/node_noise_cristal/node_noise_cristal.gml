function Node_Noise_Cristal(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Cristal Noise";
	shader = sh_noise_cristal;
	
	newInput(1, nodeValue_Vec2("Position", [ 0, 0 ] ));
		addShaderProp(SHADER_UNIFORM.float, "position");
		
	newInput(2, nodeValue_Vec2("Scale", [ 1, 1 ] ));
		addShaderProp(SHADER_UNIFORM.float, "scale");
		
	newInput(3, nodeValueSeed(self));
		addShaderProp(SHADER_UNIFORM.float, "seed");
				
	newInput(4, nodeValue_Int("Iteration", 15 ));
		addShaderProp(SHADER_UNIFORM.integer, "iteration");
		
	newInput(5, nodeValue_Color("Color", ca_white ));
		addShaderProp(SHADER_UNIFORM.color, "color");
	
	newInput(6, nodeValue_Float("Gamma", 1 ))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 2, 0.01 ] });
		addShaderProp(SHADER_UNIFORM.float, "gamma");
		
	newInput(7, nodeValue_Rotation("Phase", 0));
		addShaderProp(SHADER_UNIFORM.float, "phase");
		
	newInput(8, nodeValue_Surface("Mask"));
	
	input_display_list = [ 3, 
		["Output", 	 true],	0, 8, 
		["Noise",	false],	1, 2, 4, 7, 
		["Render",	false], 5, 6, 
	];
}