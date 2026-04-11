function Node_Wave_Interfere(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Wave Interfere";
	shader = sh_wave_interf;
	
	////- =Output
	newInput( 1, nodeValue_Surface( "UV Map"     ));
	newInput( 2, nodeValue_Slider(  "UV Mix", 1  ));
	newInput( 3, nodeValue_Surface( "Mask"       ));
	
	////- =Pattern
	newInput(11, nodeValue_EScroll( "Pattern", 0, [ "Axis", "Polar" ] )).setShaderProp("pattern");
	newInput(12, nodeValue_Vec2(    "Polar Center 1", [0,.5] )).setUnitSimple().setShaderProp("polarPos1");
	newInput(13, nodeValue_Vec2(    "Polar Center 2", [1,.5] )).setUnitSimple().setShaderProp("polarPos2");
	
	////- =Wave
	newInput( 8, nodeValue_EScroll( "Wave",         0, [ "Sine", "Zigzag" ] )).setShaderProp("type");
	newInput( 7, nodeValue_EScroll( "Post Process", 0, [ "None", "Absolute", "Normalize" ] )).setShaderProp("comp");
	newInput( 9, nodeValue_Float(   "Amplitude",   .5 )).setShaderProp("intensity");
	newInput(10, nodeValue_EScroll( "Blend Mode",   0, [ "Add", "Multiply", "Max" ] )).setShaderProp("blendMode");
	
	////- =Transform
	newInput( 5, nodeValue_Vec2(     "Position", [.5,.5] )).setUnitSimple().setShaderProp("position");
	newInput( 6, nodeValue_Rotation( "Rotation",   0     )).setShaderProp("rotation");
	newInput( 4, nodeValue_Vec2(     "Scale",     [4,4]  )).setShaderProp("scale");
	// 9
	
	input_display_list = [
		[ "Output",     true ],  0,  1,  2,  3, 
		[ "Pattern",   false ], 11, 12, 13, 
		[ "Wave",      false ],  8,  7,  9, 10, 
		[ "Transform", false ],  5,  6,  4,  
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _pat = inputs[11].getValue();
		
		if(_pat == 0) {
			var _pos = inputs[ 5].getValue();
		    var _px  = _x + _pos[0] * _s;
		    var _py  = _y + _pos[1] * _s;
		    
		    InputDrawOverlay(inputs[5].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my));
		    InputDrawOverlay(inputs[6].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my));
		    
		} else if(_pat == 1) {
		    InputDrawOverlay(inputs[12].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		    InputDrawOverlay(inputs[13].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
			
		}
	    
	    return w_hovering;
	}
	
	static onProcessData = function(_outSurf, _data, _array_index) {
		#region data
			var _patt = _data[11];
			
			inputs[12].setVisible(_patt == 1);
			inputs[13].setVisible(_patt == 1);
			
			inputs[ 5].setVisible(_patt == 0);
			inputs[ 6].setVisible(_patt == 0);
		#endregion
	}
	
}