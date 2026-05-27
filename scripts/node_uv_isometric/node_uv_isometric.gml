function Node_UV_Isometric(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "UV Isometric";
	shader = sh_uv_isometric;
	
	////- =Output
	newInput( 1, nodeValue_Surface( "UV Map"     ));
	newInput( 2, nodeValue_Slider(  "UV Mix", 1  ));
	newInput( 3, nodeValue_Surface( "Mask"       ));
	
	////- =UV
	newInput(12, nodeValue_EButton(  "Direction",   0, ["Top", "Left", "Right"]  )).setShaderProp("side");
	newInput( 4, nodeValue_Vec2(     "Position",   [0,0] )).setUnitSimple().setShaderProp("position");
	newInput(13, nodeValue_Vec2(     "Offset",     [0,0] )).setUnitSimple().setShaderProp("offset");
	newInput(10, nodeValue_Anchor(   "Anchor",     [0,0] )).setShaderProp("anchor");
	newInput( 5, nodeValue_Rotation( "Rotation",    0    )).setShaderProp("rotation");
	newInput( 6, nodeValue_Vec2(     "Scale",      [1,1] )).setShaderProp("tile");
	newInput(11, nodeValue_EScroll(  "Repeat",      1, ["Empty", "Tile", "Clamp", "Ping Pong"]  )).setShaderProp("repeat");
	newInput(14, nodeValue_Bool(     "Inverted",    false )).setShaderProp("invert");
	
	////- =Channels
	newInput( 7, nodeValue_SliRange( "X",   [0,1] )).setShaderProp("xRange");
	newInput( 8, nodeValue_SliRange( "Y",   [1,0] )).setShaderProp("yRange");
	newInput( 9, nodeValue_Slider(   "Blue", 0    )).setShaderProp("blue");
	// 15
	
	outputs[0].setCustomData(global.SURFACE_UV_JUNC);
	
	input_display_list = [
		[ "Output",    true ],  0,  1,  2,  3, 
		[ "UV",       false ], 12,  4, 13, 10,  5,  6, 11, 14, 
		[ "Channels", false ],  7,  8,  9, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _pos = inputs[13].getValue();
	    var _px  = _x + _pos[0] * _s;
	    var _py  = _y + _pos[1] * _s;
	    
	    InputDrawOverlay(inputs[13].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my));
	    InputDrawOverlay(inputs[ 5].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my));
	    
	    return w_hovering;
	}
	
}