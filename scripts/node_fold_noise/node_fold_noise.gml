function Node_Fold_Noise(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Fold Noise";
	shader = sh_noise_fold;
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
		addShaderProp(SHADER_UNIFORM.float, "position");
		
	inputs[| 2] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 2, 2 ])
		.setDisplay(VALUE_DISPLAY.vector);
		addShaderProp(SHADER_UNIFORM.float, "scale");
		
	inputs[| 3] = nodeValue("Iteration", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 6, 1] });
		addShaderProp(SHADER_UNIFORM.integer, "iteration");
		
	inputs[| 4] = nodeValue("Stretch", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 2);
		addShaderProp(SHADER_UNIFORM.float, "stretch");
		
	inputs[| 5] = nodeValue("Amplitude", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1.3)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 2, 0.01] });
		addShaderProp(SHADER_UNIFORM.float, "amplitude");
		
	inputs[| 6] = nodeValue("Mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Greyscale", "Map" ]);
		addShaderProp(SHADER_UNIFORM.integer, "mode");
				
	input_display_list = [
		["Output", 	 true],	0, 
		["Noise",	false],	1, 2, 3, 4, 5, 
		["Render",	false],	6, 
	];
}