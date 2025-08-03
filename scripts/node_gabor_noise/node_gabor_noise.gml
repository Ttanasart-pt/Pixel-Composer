function Node_Gabor_Noise(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Gabor Noise";
	shader = sh_noise_gabor;
	
	newInput(13, nodeValue_Surface("Mask"));
	newInput( 3, nodeValueSeed()).setShaderProp("seed");
	
	////- =Noise
	
	newInput( 4, nodeValue_Slider(   "Density",    2, [ 0, 4, 0.01 ] )).setShaderProp("alignment").setMappable(9);
	newInput( 7, nodeValue_Rotation( "Phase",      0                 )).setShaderProp("rotation").setMappable(11);
	newInput( 5, nodeValue_Slider(   "Sharpness",  4, [ 0, 5, 0.01 ] )).setShaderProp("sharpness").setMappable(10);
	newInput( 6, nodeValue_Vec2(     "Augment",   [11,31]            )).setShaderProp("augment");
	
	////- =Transform
	
	newInput( 1, nodeValue_Vec2(     "Position",  [0,0] )).setShaderProp("position").setUnitRef(function(i) /*=>*/ {return getDimension(i)});
	newInput(12, nodeValue_Rotation( "Rotation",   0    )).setShaderProp("trRotation");
	newInput( 2, nodeValue_Vec2(     "Scale",     [4,4] )).setShaderProp("scale").setMappable(8);
	
	// input 14
	
	input_display_list = [
		["Output",     true], 0, 13, 3, 
		["Noise",     false], 4, 9, 7, 11, 5, 10, 
		["Transform", false], 1, 12, 2, 8, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
}