function Node_Shard_Noise(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Shard Noise";
	shader = sh_noise_shard;
	
	newInput( 3, nodeValueSeed()).setShaderProp("seed");
	
	////- =Output
	newInput(11, nodeValue_Surface( "UV Map"     ));
	newInput(12, nodeValue_Slider(  "UV Mix", 1  ));
	newInput(10, nodeValue_Surface( "Mask"       ));
	
	////- =Noise
	newInput( 5, nodeValue_Float(  "Progress",  0)).setShaderProp("progress").setMappable(8).setPieMenu();
	newInput( 4, nodeValue_Slider( "Sharpness", 1, [ 0, 2, 0.01 ])).setShaderProp("sharpness").setMappable(7).setPieMenu();
	
	////- =Transform
	newInput( 1, nodeValue_Vec2(     "Position", [0,0] )).setHotkey("G").setShaderProp("position").setUnitSimple().setPieMenu();
	newInput( 9, nodeValue_Rotation( "Rotation",  0    )).setHotkey("R").setShaderProp("rotation").setPieMenu();
	newInput( 2, nodeValue_Vec2(     "Scale",    [4,4] )).setHotkey("S").setShaderProp("scale").setMappable(6).setPieMenu();
	
	////- =Rendering
	newInput(13, nodeValue_SliRange( "Level",    [0,1] )).setShaderProp("level");
	// input 14
	
	input_display_list = [ 3, 
		[ "Output",      true ],  0,  11, 12, 10, 
		[ "Noise",      false ],  5,  8,  4,  7, 
		[ "Transform",  false ],  1,  9,  2,  6, 
		[ "Rendering",  false ], 13, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _pos = getInputSingle(1);
		var  px  = _x + _pos[0] * _s;
		var  py  = _y + _pos[1] * _s;
		
		drawOverlayInput(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		drawOverlayInput(inputs[9].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my));
		drawOverlayInput(inputs[2].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my));
		
		return w_hovering;
	}
	
}