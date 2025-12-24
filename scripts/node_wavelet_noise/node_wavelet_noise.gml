function Node_Wavelet_Noise(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Wavelet Noise";
	shader = sh_noise_wavelet;
	
	////- =Output
	newInput(11, nodeValue_Surface( "UV Map"     ));
	newInput(12, nodeValue_Slider(  "UV Mix", 1  ));
	newInput(10, nodeValue_Surface( "Mask"       ));
	
	////- =Noise
	newInput( 3, nodeValueSeed()).setShaderProp("seed");
	newInput( 4, nodeValue_Float(  "Progress",   0 )).setShaderProp("progress").setMappable(7);
	newInput( 5, nodeValue_Slider( "Detail",     1.24, [ 0, 2, 0.01 ])).setShaderProp("detail").setMappable(8);
	
	////- =Transform
	newInput( 1, nodeValue_Vec2("Position",      [0,0] )).setHotkey("G").setShaderProp("position").setUnitSimple();
	newInput( 9, nodeValue_Rotation("Rotation",   0    )).setHotkey("R").setShaderProp("rotation");
	newInput( 2, nodeValue_Vec2("Scale",         [4,4] )).setHotkey("S").setShaderProp("scale").setMappable(6);
	// input 11
	
	input_display_list = [
		["Output",      true], 0, 11, 12, 10, 
		["Noise",      false], 3, 4, 7, 5, 8, 
		["Transform",  false], 1, 9, 2, 6, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _pos = getInputSingle(1);
		var  px  = _x + _pos[0] * _s;
		var  py  = _y + _pos[1] * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[9].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
}