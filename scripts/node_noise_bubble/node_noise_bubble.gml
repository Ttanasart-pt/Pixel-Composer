#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Noise_Bubble", "Mode > Toggle",       "M", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[5].setValue((_n.inputs[5].getValue() + 1) % 2); });
		addHotkey("Node_Noise_Bubble", "Blend Mode > Toggle", "B", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[7].setValue((_n.inputs[7].getValue() + 1) % 2); });
	});
#endregion

function Node_Noise_Bubble(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Bubble Noise";
	shader = sh_noise_bubble;
	
	////- =Output
	newInput( 9, nodeValue_Surface( "UV Map"     ));
	newInput(10, nodeValue_Slider(  "UV Mix", 1  ));
	newInput( 8, nodeValue_Surface( "Mask"       ));
	
	////- =Noise
	newInput( 2, nodeValueSeed()).setShaderProp("seed").setPieMenu();
	newInput( 1, nodeValue_Slider(   "Density",   .5     )).setShaderProp("density").setPieMenu();
	newInput( 3, nodeValue_SliRange( "Scale",    [.5,.8] )).setShaderProp("scale").setPieMenu();
	
	////- =Rendering
	newInput(11, nodeValue_SliRange( "Level",      [0,1] )).setShaderProp("level");
	newInput( 5, nodeValue_EButton(  "Mode",        0, [ "Line", "Fill" ] )).setShaderProp("mode").setPieMenu();
	newInput( 4, nodeValue_Slider(   "Thickness",   0                     )).setShaderProp("thickness").setPieMenu();
	newInput( 6, nodeValue_SliRange( "Opacity",    [0,1]                  )).setShaderProp("alpha").setPieMenu();
	newInput( 7, nodeValue_EScroll(  "Blend Mode",  0, [ "Max", "Add" ]   )).setShaderProp("render");
	// input 12
	
	input_display_list = [ 
		[ "Output",     true ],  0,  9, 10,  8, 
		[ "Noise",     false ],  2,  1,  3, 
		[ "Rendering", false ], 11,  5,  4,  6,  7, 
	];
}