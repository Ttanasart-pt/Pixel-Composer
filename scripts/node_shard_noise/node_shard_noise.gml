function Node_Shard_Noise(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Shard Noise";
	shader = sh_noise_shard;
	
	newInput(1, nodeValue_Vec2("Position", [ 0, 0 ]))
		.setUnitRef(function(index) { return getDimension(index); });
		addShaderProp(SHADER_UNIFORM.float, "position");
		
	newInput(2, nodeValue_Vec2("Scale", [ 4, 4 ]))
		.setMappable(6);
		addShaderProp(SHADER_UNIFORM.float, "scale");
				
	newInput(3, nodeValueSeed());
		addShaderProp(SHADER_UNIFORM.float, "seed");
				
	newInput(4, nodeValue_Float("Sharpness", 1))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 2, 0.01 ] })
		.setMappable(7);
		addShaderProp(SHADER_UNIFORM.float, "sharpness");
				
	newInput(5, nodeValue_Float("Progress", 0))
		.setMappable(8);
		addShaderProp(SHADER_UNIFORM.float, "progress")
			
	//////////////////////////////////////////////////////////////////////////////////
	
	newInput( 6, nodeValueMap("Scale map", self));		addShaderProp();
	
	newInput( 7, nodeValueMap("Sharpness map", self));	addShaderProp();
	
	newInput( 8, nodeValueMap("Progress map", self)); addShaderProp();
	
	//////////////////////////////////////////////////////////////////////////////////
	
	newInput(9, nodeValue_Rotation("Rotation", 0));
		addShaderProp(SHADER_UNIFORM.float, "rotation");
			
	newInput(10, nodeValue_Surface("Mask"));
	
	input_display_list = [
		["Output", 	 true],	0, 3, 10, 
		["Noise",	false],	1, 9, 2, 6, 5, 8, 4, 7, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
}