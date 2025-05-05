#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Perlin_Extra", "Color Mode > Toggle", "C", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[ 6].setValue((_n.inputs[ 6].getValue() + 1) % 3); });
		addHotkey("Node_Perlin_Extra", "Noise Type > Toggle", "T", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[10].setValue((_n.inputs[10].getValue() + 1) % 7); });
	});
#endregion

function Node_Perlin_Extra(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Extra Perlins";
	shader = sh_perlin_extra;
	
	newInput(1, nodeValue_Vec2("Position", self, [ 0, 0 ]))
		.setUnitRef(function(index) { return getDimension(index); });
		addShaderProp(SHADER_UNIFORM.float, "position");
		
	newInput(2, nodeValue_Vec2("Scale", self, [ 4, 4 ]))
		.setMappable(13);
		addShaderProp(SHADER_UNIFORM.float, "scale");
	
	newInput(3, nodeValue_Int("Iteration", self, 2));
		addShaderProp(SHADER_UNIFORM.integer, "iteration");
	
	newInput(4, nodeValue_Bool("Tile", self, true, "Tiling only works with integer scale, and some effect type doesn't support tiling."));
		addShaderProp(SHADER_UNIFORM.integer, "tile");
			
	newInput(5, nodeValueSeed(self));
		addShaderProp(SHADER_UNIFORM.float, "seed");
		
	newInput(6, nodeValue_Enum_Button("Color Mode", self,  0, [ "Greyscale", "RGB", "HSV" ]));
		addShaderProp(SHADER_UNIFORM.integer, "colored");
	
	newInput(7, nodeValue_Slider_Range("Color R Range", self, [ 0, 1 ]));
		addShaderProp(SHADER_UNIFORM.float, "colorRanR");
	
	newInput(8, nodeValue_Slider_Range("Color G Range", self, [ 0, 1 ]));
		addShaderProp(SHADER_UNIFORM.float, "colorRanG");
	
	newInput(9, nodeValue_Slider_Range("Color B Range", self, [ 0, 1 ]));
		addShaderProp(SHADER_UNIFORM.float, "colorRanB");
	
	newInput(10, nodeValue_Enum_Scroll("Noise Type", self, 0, [ "Absolute worley", "Fluid", "Noisy", "Camo", "Blocky", "Max", "Vine" ]));
		addShaderProp(SHADER_UNIFORM.integer, "type");
		
	newInput(11, nodeValue_Float("Parameter A", self, 0))
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(14);
		addShaderProp(SHADER_UNIFORM.float, "paramA");
		
	newInput(12, nodeValue_Float("Parameter B", self, 1))
		.setMappable(15);
		addShaderProp(SHADER_UNIFORM.float, "paramB");
		
	//////////////////////////////////////////////////////////////////////////////////
	
	newInput(13, nodeValueMap("Scale map", self));			addShaderProp();
	
	newInput(14, nodeValueMap("Parameter A map", self));	addShaderProp();
	
	newInput(15, nodeValueMap("Parameter B map", self));	addShaderProp();
	
	//////////////////////////////////////////////////////////////////////////////////
	
	newInput(16, nodeValue_Rotation("Rotation", self, 0));
		addShaderProp(SHADER_UNIFORM.float, "rotation");
			
	newInput(17, nodeValue_Surface("Mask", self));
	
	input_display_list = [
		["Output", 	 true],	0, 17, 5, 
		["Noise",	false],	10, 1, 16, 2, 13, 3, 4, 11, 14, 12, 15,
		["Render",	false], 6, 7, 8, 9, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		var hv = inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny); OVERLAY_HV
		
		return _hov;
	}
	
	static step = function() { #region
		var _col = getInputData(6);
		var _typ = getInputData(10);
		
		inputs[7].setVisible(_col != 0);
		inputs[8].setVisible(_col != 0);
		inputs[9].setVisible(_col != 0);
		
		inputs[7].name = _col == 1? "Color R Range" : "Color H Range";
		inputs[8].name = _col == 1? "Color G Range" : "Color S Range";
		inputs[9].name = _col == 1? "Color B Range" : "Color V Range";
		
		inputs[11].setVisible(_typ > 0);
		inputs[12].setVisible(false);
		
		inputs[ 2].mappableStep();
		inputs[11].mappableStep();
		inputs[12].mappableStep();
	} #endregion
}