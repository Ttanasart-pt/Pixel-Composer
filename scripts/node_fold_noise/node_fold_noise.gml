function Node_Fold_Noise(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Fold Noise";
	shader = sh_noise_fold;
	
	newInput( 9, nodeValue_Surface( "UV Map"     ));
	newInput(10, nodeValue_Slider(  "UV Mix", 1  ));
	newInput( 8, nodeValue_Surface( "Mask"       ));
	
	////- =Noise
	newInput(3, nodeValue_ISlider(  "Iteration",   2, [ 0, 6, 0.1 ]    )).setShaderProp("iteration");
	newInput(4, nodeValue_Float(    "Stretch",     2                   )).setShaderProp("stretch");
	newInput(5, nodeValue_Slider(   "Amplitude",   1.3, [ 0, 2, 0.01 ] )).setShaderProp("amplitude");
	
	////- =Transform
	newInput(1, nodeValue_Vec2(     "Position",   [0,0] )).setHotkey("G").setShaderProp("position").setUnitSimple();
	newInput(7, nodeValue_Rotation( "Rotation",    0    )).setHotkey("R").setShaderProp("rotation");
	newInput(2, nodeValue_Vec2(     "Scale",      [2,2] )).setHotkey("S").setShaderProp("scale");
	
	////- =Render
	newInput(6, nodeValue_Enum_Button( "Mode", 0, [ "Greyscale", "Map" ])).setShaderProp("mode");
	// input 9
	
	input_display_list = [
		["Output", 	   true], 0, 9, 10, 8, 
		["Noise",	  false], 3, 4, 5, 
		["Transform", false], 1, 7, 2, 
		["Render",	  false], 6, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) {
		var _pos = getSingleValue(1);
		var  px  = _x + _pos[0] * _s;
		var  py  = _y + _pos[1] * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[7].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
}