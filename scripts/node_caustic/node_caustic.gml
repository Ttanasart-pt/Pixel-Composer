function Node_Caustic(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Caustic";
	shader = sh_water_caustic;
	
	newInput(1, nodeValue_Vec2("Position", self, [ 0, 0 ]))
		.setUnitRef(function(index) { return getDimension(index); });
		addShaderProp(SHADER_UNIFORM.float, "position");
		
	newInput(2, nodeValue_Vec2("Scale", self, [ 4, 4 ]));
		addShaderProp(SHADER_UNIFORM.float, "scale");
				
	newInput(3, nodeValueSeed(self));
		addShaderProp(SHADER_UNIFORM.float, "seed");
				
	newInput(4, nodeValue_Float("Progress", self, 0));
		addShaderProp(SHADER_UNIFORM.float, "progress");
				
	newInput(5, nodeValue_Float("Detail", self, 1.24))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 2, 0.01 ] });
		addShaderProp(SHADER_UNIFORM.float, "detail");
			
	input_display_list = [
		["Output", 	 true],	0, 
		["Noise",	false],	1, 2, 4, 5, 
	];
}