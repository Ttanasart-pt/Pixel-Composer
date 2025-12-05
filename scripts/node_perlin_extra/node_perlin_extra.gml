#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Perlin_Extra", "Color Mode > Toggle", "C", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[ 6].setValue((_n.inputs[ 6].getValue() + 1) % 3); });
		addHotkey("Node_Perlin_Extra", "Noise Type > Toggle", "T", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[10].setValue((_n.inputs[10].getValue() + 1) % 7); });
	});
#endregion

function Node_Perlin_Extra(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Extra Perlins";
	shader = sh_perlin_extra;
	
	////- =Output
	newInput(18, nodeValue_Surface( "UV Map"     ));
	newInput(19, nodeValue_Slider(  "UV Mix", 1  ));
	newInput(17, nodeValue_Surface( "Mask"       ));
	
	////- =Noise
	newInput( 5, nodeValueSeed()).setShaderProp("seed");
	newInput(10, nodeValue_Enum_Scroll( "Noise Type",       0, [ "Absolute worley", "Fluid", "Noisy", "Camo", "Blocky", "Max", "Vine" ])).setShaderProp("type");
	newInput( 3, nodeValue_Int(         "Iteration",        2    )).setShaderProp("iteration");
	newInput( 4, nodeValue_Bool(        "Tile",             true )).setShaderProp("tile");
	newInput(11, nodeValue_Slider(      "Parameter A",      0    )).setShaderProp("paramA").setMappable(14);
	newInput(12, nodeValue_Float(       "Parameter B",      1    )).setShaderProp("paramB").setMappable(15);
	
	////- =Transform
	newInput( 1, nodeValue_Vec2(     "Position",    [0,0] )).setHotkey("G").setShaderProp("position").setUnitRef(function(i) /*=>*/ {return getDimension(i)});
	newInput(16, nodeValue_Rotation( "Rotation",     0    )).setHotkey("R").setShaderProp("rotation");
	newInput( 2, nodeValue_Vec2(     "Scale",       [4,4] )).setHotkey("S").setShaderProp("scale").setMappable(13);
	
	////- =Render
	newInput( 6, nodeValue_Enum_Button(  "Color Mode",     0, [ "Greyscale", "RGB", "HSV" ] )).setShaderProp("colored");
	newInput( 7, nodeValue_Slider_Range( "Color R Range", [0,1] )).setShaderProp("colorRanR");
	newInput( 8, nodeValue_Slider_Range( "Color G Range", [0,1] )).setShaderProp("colorRanG");
	newInput( 9, nodeValue_Slider_Range( "Color B Range", [0,1] )).setShaderProp("colorRanB");
	// input 20
	
	input_display_list = [
		["Output",     true], 0, 18, 19, 17, 
		["Noise",     false], 5, 10, 3, 4, 11, 14, 12, 15,
		["Transform", false], 1, 16, 2, 13, 
		["Render",    false], 6, 7, 8, 9, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _pos = getSingleValue(1);
		var  px  = _x + _pos[0] * _s;
		var  py  = _y + _pos[1] * _s;
		
		InputDrawOverlay(inputs[ 1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[16].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[ 2].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static step = function() {
		var _typ = getInputData(10);
		var _til = getInputData( 4);
		var _col = getInputData( 6);
		
		inputs[16].setVisible(!_til);
		inputs[ 2].type = _til? VALUE_TYPE.integer : VALUE_TYPE.float;
		
		inputs[7].setVisible(_col != 0);
		inputs[8].setVisible(_col != 0);
		inputs[9].setVisible(_col != 0);
		
		inputs[7].name = _col == 1? "Color R Range" : "Color H Range";
		inputs[8].name = _col == 1? "Color G Range" : "Color S Range";
		inputs[9].name = _col == 1? "Color B Range" : "Color V Range";
		
		inputs[11].setVisible(_typ > 0);
		inputs[12].setVisible(false);
	}
}