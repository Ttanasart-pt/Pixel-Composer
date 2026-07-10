function Node_Noise_Scratch(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Scratch Noise";
	shader = sh_noise_scratch;
	
	newInput( 4, nodeValueSeed()).setShaderProp("seed");
	
	////- =Output
	newInput( 1, nodeValue_Surface( "UV Map"     ));
	newInput( 2, nodeValue_Slider(  "UV Mix", 1  ));
	newInput( 3, nodeValue_Surface( "Mask"       ));
	
	////- =Transform
	newInput(10, nodeValue_Vec2(     "Position",  [0,0] )).setShaderProp("position").setUnitSimple();
	newInput(11, nodeValue_Rotation( "Rotation",   0    )).setShaderProp("rotation");
	newInput(12, nodeValue_Vec2(     "Scale",     [1,1] )).setShaderProp("scale");
	
	////- =Noise
	newInput( 5, nodeValue_Float(  "Thickness",  0 )).setMappable(15).setShaderProp("thickness");
	newInput( 6, nodeValue_Slider( "Wavyness",  .5 )).setMappable(16).setShaderProp("wavyness");
	newInput( 7, nodeValue_Float(  "Softness",   3 )).setMappable(17).setShaderProp("softness");
	
	////- =Detail
	newInput( 8, nodeValue_Int(      "Octaves",         8       )).setShaderProp("octaves");
	newInput(13, nodeValue_Vec2(     "Octave Shift",    [10,10] )).setShaderProp("octaveShift");
	newInput(14, nodeValue_Rotation( "Octave Rotation", 30      )).setShaderProp("octaveRotation");
	newInput( 9, nodeValue_Float(    "Octave Scale",    1.22    )).setShaderProp("octaveScale");
	// 18
	
	input_display_list = [
		[ "Output",     true ],  0,  1,  2,  3, 
		[ "Transform", false ], 10, 11, 12, 
		[ "Noise",     false ],  5, 15,  6, 16,  7, 17, 
		[ "Detail",    false ],  8, 13, 14,  9, 
	];
	
	////- Node
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var pos = getInputSingle(10);
		var px  = _x + pos[0] * _s;
		var py  = _y + pos[1] * _s;
		
		drawOverlayInput(inputs[10].drawOverlay(hover, active, _x, _y, _s, _mx, _my));
		drawOverlayInput(inputs[11].drawOverlay(hover, active, px, py, _s, _mx, _my));
	}
}