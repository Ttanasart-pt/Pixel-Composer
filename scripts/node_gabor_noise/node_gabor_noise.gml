function Node_Gabor_Noise(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Gabor Noise";
	shader = sh_noise_gabor;
	
	newInput( 3, nodeValueSeed()).setShaderProp("seed");
	
	newInput(14, nodeValue_Surface( "UV Map"     ));
	newInput(15, nodeValue_Slider(  "UV Mix", 1  ));
	newInput(13, nodeValue_Surface( "Mask"       ));
	
	////- =Noise
	newInput( 4, nodeValue_Slider(   "Density",    2, [ 0, 4, 0.01 ] )).setShaderProp("alignment").setMappable(9);
	newInput( 7, nodeValue_Rotation( "Phase",      0                 )).setShaderProp("rotation").setMappable(11);
	newInput( 5, nodeValue_Slider(   "Sharpness",  4, [ 0, 5, 0.01 ] )).setShaderProp("sharpness").setMappable(10);
	newInput( 6, nodeValue_Vec2(     "Augment",   [11,31]            )).setShaderProp("augment");
	
	////- =Transform
	newInput( 1, nodeValue_Vec2(     "Position",  [0,0] )).setHotkey("G").setShaderProp("position").setUnitRef(function(i) /*=>*/ {return getDimension(i)});
	newInput(12, nodeValue_Rotation( "Rotation",   0    )).setHotkey("R").setShaderProp("trRotation");
	newInput( 2, nodeValue_Vec2(     "Scale",     [4,4] )).setHotkey("S").setShaderProp("scale").setMappable(8);
	// input 16
	
	input_display_list = [ 3, 
		["Output",     true], 0, 14, 15, 13, 
		["Noise",     false], 4, 9, 7, 11, 5, 10, 
		["Transform", false], 1, 12, 2, 8, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) {
		var _pos = getSingleValue(1);
		var  px  = _x + _pos[0] * _s;
		var  py  = _y + _pos[1] * _s;
		
		InputDrawOverlay(inputs[ 1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[12].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[ 2].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
}