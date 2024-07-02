function Node_Gabor_Noise(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Gabor Noise";
	shader = sh_noise_gabor;
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
		addShaderProp(SHADER_UNIFORM.float, "position");
		
	inputs[| 2] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 4, 4 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setMappable(8);
		addShaderProp(SHADER_UNIFORM.float, "scale");
				
	inputs[| 3] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[| 3].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
		addShaderProp(SHADER_UNIFORM.float, "seed");
				
	inputs[| 4] = nodeValue("Density", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 2)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 0.01 ] })
		.setMappable(9);
		addShaderProp(SHADER_UNIFORM.float, "alignment");
				
	inputs[| 5] = nodeValue("Sharpness", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 5, 0.01 ] })
		.setMappable(10);
		addShaderProp(SHADER_UNIFORM.float, "sharpness");
				
	inputs[| 6] = nodeValue("Augment", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 11, 31 ])
		.setDisplay(VALUE_DISPLAY.vector);
		addShaderProp(SHADER_UNIFORM.float, "augment");
		
	inputs[| 7] = nodeValue("Phase", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation)
		.setMappable(11);
		addShaderProp(SHADER_UNIFORM.float, "rotation");
		
	//////////////////////////////////////////////////////////////////////////////////
	
	inputs[|  8] = nodeValueMap("Scale map", self);		addShaderProp();
	
	inputs[|  9] = nodeValueMap("Density map", self);	addShaderProp();
	
	inputs[| 10] = nodeValueMap("Sharpness map", self); addShaderProp();
	
	inputs[| 11] = nodeValueMap("Phase map", self);		addShaderProp();
		
	//////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 12] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
		addShaderProp(SHADER_UNIFORM.float, "trRotation");
			
	input_display_list = [
		["Output", 	 true],	0, 3, 
		["Noise",	false],	1, 12, 2, 8, 4, 9, 7, 11, 5, 10, 
	];
	
	static step = function() {
		inputs[| 2].mappableStep();
		inputs[| 4].mappableStep();
		inputs[| 5].mappableStep();
		inputs[| 7].mappableStep();
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		var  hv  = inputs[| 1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	}
	
}