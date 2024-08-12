function Node_Fold_Noise(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Fold Noise";
	shader = sh_noise_fold;
	
	inputs[1] = nodeValue_Vec2("Position", self, [ 0, 0 ])
		.setUnitRef(function(index) { return getDimension(index); });
		addShaderProp(SHADER_UNIFORM.float, "position");
		
	inputs[2] = nodeValue_Vec2("Scale", self, [ 2, 2 ]);
		addShaderProp(SHADER_UNIFORM.float, "scale");
		
	inputs[3] = nodeValue_Int("Iteration", self, 2)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 6, 0.1] });
		addShaderProp(SHADER_UNIFORM.integer, "iteration");
		
	inputs[4] = nodeValue_Float("Stretch", self, 2);
		addShaderProp(SHADER_UNIFORM.float, "stretch");
		
	inputs[5] = nodeValue_Float("Amplitude", self, 1.3)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 2, 0.01] });
		addShaderProp(SHADER_UNIFORM.float, "amplitude");
		
	inputs[6] = nodeValue_Enum_Button("Mode", self,  0, [ "Greyscale", "Map" ]);
		addShaderProp(SHADER_UNIFORM.integer, "mode");
				
	inputs[7] = nodeValue_Rotation("Rotation", self, 0);
		addShaderProp(SHADER_UNIFORM.float, "rotation");
		
	input_display_list = [
		["Output", 	 true],	0, 
		["Noise",	false],	1, 7, 2, 3, 4, 5, 
		["Render",	false],	6, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		var  hv  = inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	}
}