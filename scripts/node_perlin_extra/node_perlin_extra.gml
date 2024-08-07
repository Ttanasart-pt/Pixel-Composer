function Node_Perlin_Extra(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Extra Perlins";
	shader = sh_perlin_extra;
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
		addShaderProp(SHADER_UNIFORM.float, "position");
		
	inputs[| 2] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 4, 4 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setMappable(13);
		addShaderProp(SHADER_UNIFORM.float, "scale");
	
	inputs[| 3] = nodeValue("Iteration", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2);
		addShaderProp(SHADER_UNIFORM.integer, "iteration");
	
	inputs[| 4] = nodeValue("Tile", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true, "Tiling only works with integer scale, and some effect type doesn't support tiling.");
		addShaderProp(SHADER_UNIFORM.integer, "tile");
			
	inputs[| 5] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[| 5].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
		addShaderProp(SHADER_UNIFORM.float, "seed");
		
	inputs[| 6] = nodeValue_Enum_Button("Color mode", self,  0, [ "Greyscale", "RGB", "HSV" ]);
		addShaderProp(SHADER_UNIFORM.integer, "colored");
	
	inputs[| 7] = nodeValue("Color R range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
		addShaderProp(SHADER_UNIFORM.float, "colorRanR");
	
	inputs[| 8] = nodeValue("Color G range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
		addShaderProp(SHADER_UNIFORM.float, "colorRanG");
	
	inputs[| 9] = nodeValue("Color B range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
		addShaderProp(SHADER_UNIFORM.float, "colorRanB");
	
	inputs[| 10] = nodeValue_Enum_Scroll("Noise type", self,  0, [ "Absolute worley", "Fluid", "Noisy", "Camo", "Blocky", "Max", "Vine" ]);
		addShaderProp(SHADER_UNIFORM.integer, "type");
		
	inputs[| 11] = nodeValue("Parameter A", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(14);
		addShaderProp(SHADER_UNIFORM.float, "paramA");
		
	inputs[| 12] = nodeValue("Parameter B", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setMappable(15);
		addShaderProp(SHADER_UNIFORM.float, "paramB");
		
	//////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 13] = nodeValueMap("Scale map", self);			addShaderProp();
	
	inputs[| 14] = nodeValueMap("Parameter A map", self);	addShaderProp();
	
	inputs[| 15] = nodeValueMap("Parameter B map", self);	addShaderProp();
	
	//////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 16] = nodeValue_Rotation("Rotation", self, 0);
		addShaderProp(SHADER_UNIFORM.float, "rotation");
			
	input_display_list = [
		["Output", 	 true],	0, 5, 
		["Noise",	false],	10, 1, 16, 2, 13, 3, 4, 11, 14, 12, 15,
		["Render",	false], 6, 7, 8, 9, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		var  hv  = inputs[| 1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	}
	
	static step = function() { #region
		var _col = getInputData(6);
		var _typ = getInputData(10);
		
		inputs[| 7].setVisible(_col != 0);
		inputs[| 8].setVisible(_col != 0);
		inputs[| 9].setVisible(_col != 0);
		
		inputs[| 7].name = _col == 1? "Color R range" : "Color H range";
		inputs[| 8].name = _col == 1? "Color G range" : "Color S range";
		inputs[| 9].name = _col == 1? "Color B range" : "Color V range";
		
		inputs[| 11].setVisible(_typ > 0);
		inputs[| 12].setVisible(false);
		
		inputs[|  2].mappableStep();
		inputs[| 11].mappableStep();
		inputs[| 12].mappableStep();
	} #endregion
}