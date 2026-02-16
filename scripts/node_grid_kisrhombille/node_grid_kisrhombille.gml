function Node_Kisrhombille(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Kisrhombille";
	shader = sh_kisrhombille;
	
	newInput(12, nodeValueSeed()).setShaderProp("seed");
	
	////- =Output
	newInput( 1, nodeValue_Surface( "UV Map"     ));
	newInput( 2, nodeValue_Slider(  "UV Mix", 1  ));
	newInput( 3, nodeValue_Surface( "Mask"       ));
	
	////- =Transform
	newInput( 4, nodeValue_Vec2(     "Position", [.5,.5]     )).setHotkey("G").setShaderProp("position").setUnitSimple();
	newInput( 6, nodeValue_Rotation( "Angle",    0           )).setShaderProp("rotation");
	newInput( 5, nodeValue_Vec2(     "Scale",    [.125,.125] )).setHotkey("S").setShaderProp("scale").setUnitSimple();
	
	////- =Render
	newInput(10, nodeValue_EScroll(  "Grouping",     0, [ "None", "3-6 Deltoidal", "Rhombile", "Triakis Triangular" ])).setShaderProp("group");
	newInput( 9, nodeValue_EScroll(  "Render Type",  0, [ "Checker", "Random Color" ])).setShaderProp("type");
	newInput( 7, nodeValue_Color(    "Color 1", ca_black )).setShaderProp("color1");
	newInput( 8, nodeValue_Color(    "Color 2", ca_white )).setShaderProp("color2");
	newInput(11, nodeValue_Gradient( "Colors",  gra_black_white )).setShaderProp("gradient");
	// 13
	
	input_display_list = [ 12, 
		[ "Output",     true ],  0,  1,  2,  3, 
		[ "Transform", false ],  4,  6,  5, 
		[ "Render",    false ], 10,  9,  7,  8, 11, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _pos = inputs[4].getValue();
	    var _px  = _x + _pos[0] * _s;
	    var _py  = _y + _pos[1] * _s;
	    
	    InputDrawOverlay(inputs[4].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my));
	    InputDrawOverlay(inputs[6].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my));
	    InputDrawOverlay(inputs[5].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, 0, [ 1 + sqrt(3), sqrt(3) ] ));
	    
	    return w_hovering;
	}
	
	static onProcessData = function(_outSurf, _data, _array_index) {
		var _group = _data[10];
		var _rende = _data[ 9];
		
		inputs[ 7].setVisible(_rende == 0);
		inputs[ 8].setVisible(_rende == 0);
		inputs[12].setVisible(_rende == 1);
		inputs[11].setVisible(_rende == 1);
	}
	
}