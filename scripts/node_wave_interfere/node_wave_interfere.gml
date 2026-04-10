function Node_Wave_Interfere(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Wave Interfere";
	shader = sh_wave_interf;
	
	////- =Output
	newInput( 1, nodeValue_Surface( "UV Map"     ));
	newInput( 2, nodeValue_Slider(  "UV Mix", 1  ));
	newInput( 3, nodeValue_Surface( "Mask"       ));
	
	////- =Wave
	newInput( 8, nodeValue_EScroll( "Wave",         0, [ "Sine", "Zigzag" ] )).setShaderProp("type");
	newInput( 7, nodeValue_EScroll( "Post Process", 0, [ "None", "Absolute", "Normalize" ] )).setShaderProp("comp");
	newInput( 9, nodeValue_Float(   "Amplitude",   .5 )).setShaderProp("intensity");
	newInput(10, nodeValue_EScroll( "Blend Mode",   0, [ "Add", "Multiply" ] )).setShaderProp("blendMode");
	
	////- =Transform
	newInput( 5, nodeValue_Vec2(     "Position", [.5,.5] )).setUnitSimple().setShaderProp("position");
	newInput( 6, nodeValue_Rotation( "Rotation",   0     )).setShaderProp("rotation");
	newInput( 4, nodeValue_Vec2(     "Scale",     [4,4]  )).setShaderProp("scale");
	// 9
	
	input_display_list = [
		[ "Output",     true ],  0,  1,  2,  3, 
		[ "Wave",      false ],  8,  7,  9, 10, 
		[ "Transform", false ],  5,  6,  4,  
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _pos = inputs[5].getValue();
	    var _px  = _x + _pos[0] * _s;
	    var _py  = _y + _pos[1] * _s;
	    
	    InputDrawOverlay(inputs[5].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my));
	    InputDrawOverlay(inputs[6].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my));
	    
	    return w_hovering;
	}
	
}