function Node_Gabor_Noise(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Gabor Noise";
	shader = sh_noise_gabor;
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
		addShaderProp(SHADER_UNIFORM.float, "position");
		
	inputs[| 2] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 4, 4 ])
		.setDisplay(VALUE_DISPLAY.vector);
		addShaderProp(SHADER_UNIFORM.float, "scale");
				
	inputs[| 3] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, irandom(99999));
		addShaderProp(SHADER_UNIFORM.float, "seed");
				
	inputs[| 4] = nodeValue("Density", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 2)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 0.01 ] });
		addShaderProp(SHADER_UNIFORM.float, "alignment");
				
	inputs[| 5] = nodeValue("Sharpness", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 5, 0.01 ] });
		addShaderProp(SHADER_UNIFORM.float, "sharpness");
				
	inputs[| 6] = nodeValue("Augment", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 11, 31 ])
		.setDisplay(VALUE_DISPLAY.vector);
		addShaderProp(SHADER_UNIFORM.float, "augment");
		
	inputs[| 7] = nodeValue("Phase", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
		addShaderProp(SHADER_UNIFORM.float, "rotation");
		
	input_display_list = [
		["Output", 	 true],	0, 3, 
		["Noise",	false],	1, 2, 4, 7, 5, 
	];
}