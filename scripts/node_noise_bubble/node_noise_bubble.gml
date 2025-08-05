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
	newInput(8, nodeValue_Surface("Mask"));
	
	////- =Noise
	newInput(2, nodeValueSeed()).setShaderProp("seed");
	newInput(1, nodeValue_Slider(       "Density",   .5     )).setShaderProp("density");
	newInput(3, nodeValue_Slider_Range( "Scale",    [.5,.8] )).setShaderProp("scale");
	
	////- =Render
	newInput(5, nodeValue_Enum_Button(  "Mode",        0, [ "Line", "Fill" ] )).setShaderProp("mode");
	newInput(4, nodeValue_Slider(       "Thickness",   0                     )).setShaderProp("thickness");
	newInput(6, nodeValue_Slider_Range( "Opacity",    [0,1]                  )).setShaderProp("alpha");
	newInput(7, nodeValue_Enum_Scroll(  "Blend Mode",  0, [ "Max", "Add" ]   )).setShaderProp("render");
	// input 9
	
	input_display_list = [ 
		["Output", 	 true],	0, 8, 
		["Noise",	false],	2, 1, 3, 
		["Render",	false], 5, 4, 6, 7, 
	];
}