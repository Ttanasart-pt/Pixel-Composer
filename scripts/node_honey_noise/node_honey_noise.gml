#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Honeycomb_Noise", "Mode > Toggle", "M", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[4].setValue((_n.inputs[4].getValue() + 1) % 2); });
	});
#endregion

 function Node_Honeycomb_Noise(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Honeycomb Noise";
	shader = sh_noise_honey;
	
	////- =Output
	newInput( 8, nodeValue_Surface( "UV Map"     ));
	newInput( 9, nodeValue_Slider(  "UV Mix", 1  ));
	newInput( 7, nodeValue_Surface( "Mask"       ));
	
	////- =Noise
	newInput( 5, nodeValueSeed()).setShaderProp("seed").setPieMenu();
	newInput( 4, nodeValue_EButton(  "Mode",       0, [ "Hexagon", "Star" ])).setShaderProp("mode").setPieMenu();
	newInput( 6, nodeValue_Int(      "Iteration",  1)).setShaderProp("iteration").setPieMenu();
	
	////- =Transform
	newInput( 1, nodeValue_Vec2(     "Position",  [0,0] )).setHotkey("G").setShaderProp("position").setUnitSimple().setPieMenu();
	newInput( 3, nodeValue_Rotation( "Rotation",   0    )).setHotkey("R").setShaderProp("rotation").setPieMenu();
	newInput( 2, nodeValue_Vec2(     "Scale",     [2,2] )).setHotkey("S").setShaderProp("scale").setPieMenu();
	
	////- =Rendering
	newInput(10, nodeValue_SliRange( "Level",     [0,1] )).setShaderProp("level");
	// input 11
	
	input_display_list = [ 
		[ "Output",     true ],  0,  8,  9,  7, 
		[ "Noise",     false ],  5,  4,  6, 
		[ "Transform", false ],  1,  3,  2, 
		[ "Rendering", false ], 10, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _pos = getInputSingle(1);
		var  px  = _x + _pos[0] * _s;
		var  py  = _y + _pos[1] * _s;
		
		drawOverlayInput(inputs[ 1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		drawOverlayInput(inputs[ 3].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my));
		drawOverlayInput(inputs[ 2].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my));

		return w_hovering;
	}
}