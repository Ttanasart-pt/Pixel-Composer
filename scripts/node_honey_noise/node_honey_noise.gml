#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Honeycomb_Noise", "Mode > Toggle", "M", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[4].setValue((_n.inputs[4].getValue() + 1) % 2); });
	});
#endregion

function Node_Honeycomb_Noise(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Honeycomb Noise";
	shader = sh_noise_honey;
	
	newInput(1, nodeValue_Vec2("Position", [ 0, 0 ]))
		.setUnitRef(function(index) { return getDimension(index); });
		addShaderProp(SHADER_UNIFORM.float, "position");
		
	newInput(2, nodeValue_Vec2("Scale", [ 2, 2 ]));
		addShaderProp(SHADER_UNIFORM.float, "scale");
				
	newInput(3, nodeValue_Rotation("Rotation", 0));
		addShaderProp(SHADER_UNIFORM.float, "rotation");
		
	newInput(4, nodeValue_Enum_Button("Mode",  0, [ "Hexagon", "Star" ]));
		addShaderProp(SHADER_UNIFORM.integer, "mode");
	
	newInput(5, nodeValueSeed());
		addShaderProp(SHADER_UNIFORM.float, "seed");
		
	newInput(6, nodeValue_Int("Iteration", 1));
		addShaderProp(SHADER_UNIFORM.integer, "iteration");
	
	newInput(7, nodeValue_Surface("Mask"));
	
	input_display_list = [ 5, 
		["Output", 	 true],	0, 7, 
		["Noise",	false],	1, 2, 3, 4, 6. 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));

		return w_hovering;
	}
}