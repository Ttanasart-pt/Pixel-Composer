function Node_Shard_Noise(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Shard Noise";
	shader = sh_noise_shard;
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
		addShaderProp(SHADER_UNIFORM.float, "position");
		
	inputs[| 2] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 4, 4 ])
		.setDisplay(VALUE_DISPLAY.vector);
		addShaderProp(SHADER_UNIFORM.float, "scale");
				
	inputs[| 3] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, irandom(99999));
		addShaderProp(SHADER_UNIFORM.float, "seed");
				
	inputs[| 4] = nodeValue("Sharpness", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 2, 0.01 ] });
		addShaderProp(SHADER_UNIFORM.float, "sharpness");
				
	inputs[| 5] = nodeValue("Progress", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		addShaderProp(SHADER_UNIFORM.float, "progress");
			
	input_display_list = [
		["Output", 	 true],	0, 3, 
		["Noise",	false],	1, 2, 5, 4, 
	];
}