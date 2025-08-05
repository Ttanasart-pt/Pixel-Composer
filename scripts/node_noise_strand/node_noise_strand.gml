#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Noise_Strand", "Mode > Toggle", "M", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[10].setValue((_n.inputs[10].getValue() + 1) % 2); });
		addHotkey("Node_Noise_Strand", "Axis > Toggle", "A", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[ 9].setValue((_n.inputs[ 9].getValue() + 1) % 2); });
	});
#endregion

function Node_Noise_Strand(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Strand Noise";
	shader = sh_noise_strand;
	
	////- =Output
	newInput(12, nodeValue_Surface("Mask"));
	
	////- =Noise
	newInput( 3, nodeValueSeed()).setShaderProp("seed");
	newInput( 9, nodeValue_Enum_Button( "Axis",     0, [ "X", "Y" ] )).setShaderProp("axis");
	newInput( 2, nodeValue_Slider(      "Density", .5 )).setShaderProp("density");
	newInput( 4, nodeValue_Slider(      "Slope",   .5 )).setShaderProp("slope");
	
	////- =Transform
	newInput( 1, nodeValue_Vec2( "Position", [ 0, 0 ] )).setHotkey("G").setShaderProp("position").setUnitRef(function(i) /*=>*/ {return getDimension(i)});
	
	////- =Curve
	newInput( 5, nodeValue_Slider_Range( "Curve",       [0,0], [ 0, 4, 0.01 ] )).setShaderProp("curve");
	newInput( 6, nodeValue_Float(        "Curve scale",  1 )).setShaderProp("curveDetail");
	newInput( 8, nodeValue_Float(        "Curve shift",  0 )).setShaderProp("curveShift");
	
	////- =Render
	newInput(10, nodeValue_Enum_Button(  "Mode",         0 , [ "Line", "Area" ] )).setShaderProp("mode");
	newInput( 7, nodeValue_Slider(       "Thickness",    0    )).setShaderProp("thickness");
	newInput(11, nodeValue_Slider_Range( "Opacity",     [0,1] )).setShaderProp("alpha");
	// input 13
	
	input_display_list = [ 
		["Output",      true], 0, 12, 
		["Noise",      false], 3, 9, 2, 4, 
		["Transform",  false], 1, 
		["Curve",      false], 5, 6, 8, 
		["Render",     false], 10, 7, 11, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}

}