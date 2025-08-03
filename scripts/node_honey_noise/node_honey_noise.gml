#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Honeycomb_Noise", "Mode > Toggle", "M", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[4].setValue((_n.inputs[4].getValue() + 1) % 2); });
	});
#endregion

function Node_Honeycomb_Noise(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Honeycomb Noise";
	shader = sh_noise_honey;
	
	////- =Output
	
	newInput(7, nodeValue_Surface("Mask"));
	
	////- =Noise
	
	newInput(5, nodeValueSeed()).setShaderProp("seed");
	newInput(4, nodeValue_Enum_Button( "Mode",       0, [ "Hexagon", "Star" ])).setShaderProp("mode");
	newInput(6, nodeValue_Int(         "Iteration",  1)).setShaderProp("iteration");
	
	////- =Transform
	
	newInput(1, nodeValue_Vec2(        "Position",  [0,0] )).setShaderProp("position").setUnitRef(function(i) /*=>*/ {return getDimension(i)});
	newInput(3, nodeValue_Rotation(    "Rotation",   0    )).setShaderProp("rotation");
	newInput(2, nodeValue_Vec2(        "Scale",     [2,2] )).setShaderProp("scale");
	
	input_display_list = [ 
		["Output",     true], 0, 7, 
		["Noise",     false], 5, 4, 6, 
		["Transform", false], 1, 3, 2, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));

		return w_hovering;
	}
}