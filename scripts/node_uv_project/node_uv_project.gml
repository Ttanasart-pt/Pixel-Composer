function Node_UV_Project(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "UV Project";
	shader = sh_uv_project;
	
	////- =Output
	newInput( 1, nodeValue_Surface( "UV Map"     ));
	newInput( 2, nodeValue_Slider(  "UV Mix", 1  ));
	newInput( 3, nodeValue_Surface( "Mask"       ));
	
	////- =UV
	newInput( 4, nodeValue_Vec2(     "Position",   [.5,.5] )).setUnitSimple().setShaderProp("position");
	newInput(10, nodeValue_Anchor(   "Anchor",     [.5,.5] )).setShaderProp("anchor");
	newInput( 5, nodeValue_Rotation( "Rotation",    0      )).setShaderProp("rotation");
	newInput( 6, nodeValue_Vec2(     "Tile Scale", [1,1]   )).setShaderProp("tile");
	newInput(11, nodeValue_EScroll(  "Repeat",      1, ["Empty", "Tile", "Clamp", "Ping Pong"]  )).setShaderProp("repeat");
	
	////- =Channels
	newInput( 7, nodeValue_Slider_Range( "X",   [0,1] )).setShaderProp("xRange");
	newInput( 8, nodeValue_Slider_Range( "Y",   [1,0] )).setShaderProp("yRange");
	newInput( 9, nodeValue_Slider(     "Blue",   0    )).setShaderProp("blue");
	// 12
	
	input_display_list = [
		[ "Output",    true ],  0,  1,  2,  3, 
		[ "UV",       false ],  4, 10,  5,  6, 11, 
		[ "Channels", false ],  7,  8,  9, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _pos = inputs[4].getValue();
	    var _px  = _x + _pos[0] * _s;
	    var _py  = _y + _pos[1] * _s;
	    
	    InputDrawOverlay(inputs[4].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my));
	    InputDrawOverlay(inputs[5].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my));
	    
	    return w_hovering;
	}
	
}