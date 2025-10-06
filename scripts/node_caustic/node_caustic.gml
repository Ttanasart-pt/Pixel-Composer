function Node_Caustic(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Caustic";
	shader = sh_water_caustic;
	
	////- =Output
	newInput(7, nodeValue_Surface("Mask"));
	
	////- =Noise
	newInput(3, nodeValueSeed()).setShaderProp("seed");
	newInput(4, nodeValue_Float(  "Progress",  0               )).setShaderProp("progress");
	newInput(5, nodeValue_Slider( "Detail",    1.24, [0,2,.01] )).setShaderProp("detail");
	newInput(6, nodeValue_Slider( "Intensity", 1,    [0,4,.01] )).setShaderProp("intensity");
	
	////- =Transform
	newInput(1, nodeValue_Vec2(   "Position", [0,0]   )).setHotkey("G").setShaderProp("position").setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	newInput(2, nodeValue_Vec2(   "Scale",    [.5,.5] )).setHotkey("S").setShaderProp("scale").setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	
	input_display_list = [
		["Output",     true], 0, 7, 
		["Noise",     false], 6, 4, 5, 
		["Transform", false], 1, 2, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _pos = current_data[1];
	    var _px  = _x + _pos[0] * _s;
	    var _py  = _y + _pos[1] * _s;
	    
	    InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my, _snx, _sny));
	    InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny));
	    
	    return w_hovering;
	}
	
}