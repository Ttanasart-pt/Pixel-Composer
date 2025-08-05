function Node_Shard_Noise(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Shard Noise";
	shader = sh_noise_shard;
	
	////- =Output
	newInput( 3, nodeValueSeed()).setShaderProp("seed");
	newInput(10, nodeValue_Surface( "Mask" ));
	
	////- =Noise
	newInput( 5, nodeValue_Float(  "Progress",  0)).setShaderProp("progress").setMappable(8)
	newInput( 4, nodeValue_Slider( "Sharpness", 1, [ 0, 2, 0.01 ])).setShaderProp("sharpness").setMappable(7);
	
	////- =Transform
	newInput( 1, nodeValue_Vec2(     "Position", [0,0] )).setHotkey("G").setShaderProp("position").setUnitRef(function(i) /*=>*/ {return getDimension(i)});
	newInput( 9, nodeValue_Rotation( "Rotation",  0    )).setHotkey("R").setShaderProp("rotation");
	newInput( 2, nodeValue_Vec2(     "Scale",    [4,4] )).setHotkey("S").setShaderProp("scale").setMappable(6);
	// input 11
	
	input_display_list = [
		["Output",      true], 0, 3, 10, 
		["Noise",      false], 5, 8, 4, 7, 
		["Transform",  false], 1, 9, 2, 6, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _pos = getSingleValue(1);
		var  px  = _x + _pos[0] * _s;
		var  py  = _y + _pos[1] * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[9].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
}