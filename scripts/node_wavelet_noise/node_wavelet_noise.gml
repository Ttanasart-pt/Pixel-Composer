function Node_Wavelet_Noise(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Wavelet Noise";
	shader = sh_noise_wavelet;
	
	newInput(1, nodeValue_Vec2("Position", [ 0, 0 ]))
		.setUnitRef(function(index) { return getDimension(index); });
		addShaderProp(SHADER_UNIFORM.float, "position");
		
	newInput(2, nodeValue_Vec2("Scale", [ 4, 4 ]))
		.setMappable(6);
		addShaderProp(SHADER_UNIFORM.float, "scale");
				
	newInput(3, nodeValueSeed(self));
		addShaderProp(SHADER_UNIFORM.float, "seed");
				
	newInput(4, nodeValue_Float("Progress", 0))
		.setMappable(7)
		addShaderProp(SHADER_UNIFORM.float, "progress");
				
	newInput(5, nodeValue_Float("Detail", 1.24))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 2, 0.01 ] })
		.setMappable(8);
		addShaderProp(SHADER_UNIFORM.float, "detail");
			
	//////////////////////////////////////////////////////////////////////////////////
	
	newInput( 6, nodeValueMap("Scale map", self));		addShaderProp();
	
	newInput( 7, nodeValueMap("Progress map", self));	addShaderProp();
	
	newInput( 8, nodeValueMap("Detail map", self));	addShaderProp();
		
	//////////////////////////////////////////////////////////////////////////////////
	
	newInput(9, nodeValue_Rotation("Rotation", 0));
		addShaderProp(SHADER_UNIFORM.float, "rotation");
		
	newInput(10, nodeValue_Surface("Mask"));
	
	input_display_list = [
		["Output", 	 true],	0, 10, 3, 
		["Noise",	false],	1, 9, 2, 6, 4, 7, 5, 8, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		return w_hovering;
	}
	
}