function Node_Caustic(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Caustic";
	shader = sh_water_caustic;
	
	////- =Output
	newInput(8, nodeValue_Surface( "UV Map"     ));
	newInput(9, nodeValue_Slider(  "UV Mix", 1  ));
	newInput(7, nodeValue_Surface( "Mask"       ));
	
	////- =Noise
	newInput(3, nodeValueSeed()).setShaderProp("seed");
	newInput(6, nodeValue_Slider( "Intensity", 1, [0,4,.01] )).setShaderProp("intensity").setMappable(10);
	newInput(4, nodeValue_Float(  "Progress",  0            )).setShaderProp("progress" ).setMappable(11);
	newInput(5, nodeValue_Int(    "Detail",    1            )).setShaderProp("detail"   );
	
	////- =Transform
	newInput(1, nodeValue_Vec2(   "Position", [0,0]   )).setHotkey("G").setShaderProp("position").setUnitSimple();
	newInput(2, nodeValue_Vec2(   "Scale",    [.5,.5] )).setHotkey("S").setShaderProp("scale").setUnitSimple();
	// 12
	
	input_display_list = [
		[ "Output",     true ],  0,  8,  9,  7, 
		[ "Noise",     false ],  6, 10,  4, 11,  5, 
		[ "Transform", false ],  1,  2, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _pos = inputs[1].getValue();
	    var _px  = _x + _pos[0] * _s;
	    var _py  = _y + _pos[1] * _s;
	    
	    InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my, _snx, _sny));
	    InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny));
	    
	    return w_hovering;
	}
	
}