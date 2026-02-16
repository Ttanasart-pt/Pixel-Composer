function Node_UV_Area(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "UV Area";
	shader = sh_uv_area;
	
	////- =Output
	newInput( 1, nodeValue_Surface( "UV Map"     ));
	newInput( 2, nodeValue_Slider(  "UV Mix", 1  ));
	newInput( 3, nodeValue_Surface( "Mask"       ));
	
	////- =UV
	newInput( 4, nodeValue_Area(     "Area",     DEF_AREA_REF, { useShape : false } )).setUnitSimple().setShaderProp("area");
	newInput( 5, nodeValue_Rotation( "Rotation",    0    )).setShaderProp("rotation");
	newInput( 6, nodeValue_Vec2(     "Tile Scale", [1,1] )).setShaderProp("tile");
	newInput( 7, nodeValue_EScroll(  "Repeat",      1, ["Empty", "Tile", "Clamp", "Ping Pong"]  )).setShaderProp("repeat");
	newInput(11, nodeValue_Bool(     "Invert",     false )).setShaderProp("invert");
	
	////- =Channels
	newInput( 8, nodeValue_Slider_Range( "X",   [0,1] )).setShaderProp("xRange");
	newInput( 9, nodeValue_Slider_Range( "Y",   [1,0] )).setShaderProp("yRange");
	newInput(10, nodeValue_Slider(     "Blue",   0    )).setShaderProp("blue");
	// 12
	
	input_display_list = [
		[ "Output",    true ],  0,  1,  2,  3, 
		[ "UV",       false ],  4,  5,  6,  7, 11, 
		[ "Channels", false ],  8,  9, 10, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _pos = inputs[4].getValue();
	    var _px  = _x + _pos[0] * _s;
	    var _py  = _y + _pos[1] * _s;
	    
	    InputDrawOverlay(inputs[4].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my));
	    
	    return w_hovering;
	}
	
}