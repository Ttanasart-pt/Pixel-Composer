function Node_Gabor_Noise(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Gabor Noise";
	shader = sh_noise_gabor;
	
	newInput(1, nodeValue_Vec2("Position", [ 0, 0 ]))
		.setUnitRef(function(index) { return getDimension(index); });
		addShaderProp(SHADER_UNIFORM.float, "position");
		
	newInput(2, nodeValue_Vec2("Scale", [ 4, 4 ]))
		.setMappable(8);
		addShaderProp(SHADER_UNIFORM.float, "scale");
				
	newInput(3, nodeValueSeed());
		addShaderProp(SHADER_UNIFORM.float, "seed");
				
	newInput(4, nodeValue_Float("Density", 2))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 0.01 ] })
		.setMappable(9);
		addShaderProp(SHADER_UNIFORM.float, "alignment");
				
	newInput(5, nodeValue_Float("Sharpness", 4))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 5, 0.01 ] })
		.setMappable(10);
		addShaderProp(SHADER_UNIFORM.float, "sharpness");
				
	newInput(6, nodeValue_Vec2("Augment", [ 11, 31 ]));
		addShaderProp(SHADER_UNIFORM.float, "augment");
		
	newInput(7, nodeValue_Rotation("Phase", 0))
		.setMappable(11);
		addShaderProp(SHADER_UNIFORM.float, "rotation");
		
	//////////////////////////////////////////////////////////////////////////////////
	
	newInput( 8, nodeValueMap("Scale map", self));		addShaderProp();
	
	newInput( 9, nodeValueMap("Density map", self));	addShaderProp();
	
	newInput(10, nodeValueMap("Sharpness map", self)); addShaderProp();
	
	newInput(11, nodeValueMap("Phase map", self));		addShaderProp();
		
	//////////////////////////////////////////////////////////////////////////////////
	
	newInput(12, nodeValue_Rotation("Rotation", 0));
		addShaderProp(SHADER_UNIFORM.float, "trRotation");
			
	newInput(13, nodeValue_Surface("Mask"));
	
	input_display_list = [
		["Output", 	 true],	0, 13, 3, 
		["Noise",	false],	1, 12, 2, 8, 4, 9, 7, 11, 5, 10, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
}