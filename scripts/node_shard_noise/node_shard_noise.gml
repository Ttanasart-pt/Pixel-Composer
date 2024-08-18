function Node_Shard_Noise(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Shard Noise";
	shader = sh_noise_shard;
	
	newInput(1, nodeValue_Vec2("Position", self, [ 0, 0 ]))
		.setUnitRef(function(index) { return getDimension(index); });
		addShaderProp(SHADER_UNIFORM.float, "position");
		
	newInput(2, nodeValue_Vec2("Scale", self, [ 4, 4 ]))
		.setMappable(6);
		addShaderProp(SHADER_UNIFORM.float, "scale");
				
	newInput(3, nodeValue_Float("Seed", self, seed_random(6)))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[3].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
		addShaderProp(SHADER_UNIFORM.float, "seed");
				
	newInput(4, nodeValue_Float("Sharpness", self, 1))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 2, 0.01 ] })
		.setMappable(7);
		addShaderProp(SHADER_UNIFORM.float, "sharpness");
				
	newInput(5, nodeValue_Float("Progress", self, 0))
		.setMappable(8);
		addShaderProp(SHADER_UNIFORM.float, "progress")
			
	//////////////////////////////////////////////////////////////////////////////////
	
	newInput( 6, nodeValueMap("Scale map", self));		addShaderProp();
	
	newInput( 7, nodeValueMap("Sharpness map", self));	addShaderProp();
	
	newInput( 8, nodeValueMap("Progress map", self)); addShaderProp();
	
	//////////////////////////////////////////////////////////////////////////////////
	
	newInput(9, nodeValue_Rotation("Rotation", self, 0));
		addShaderProp(SHADER_UNIFORM.float, "rotation");
			
	input_display_list = [
		["Output", 	 true],	0, 3, 
		["Noise",	false],	1, 9, 2, 6, 5, 8, 4, 7, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		var  hv  = inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	}
	
	static step = function() {
		inputs[2].mappableStep();
		inputs[4].mappableStep();
		inputs[5].mappableStep();
	}
	
}