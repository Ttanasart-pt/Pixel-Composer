function Node_Noise_Cristal(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Cristal Noise";
	shader = sh_noise_cristal;
	
	////- =Output
	newInput( 9, nodeValue_Surface( "UV Map"     ));
	newInput(10, nodeValue_Slider(  "UV Mix", 1  ));
	newInput( 8, nodeValue_Surface( "Mask"       ));
	
	////- =Noise
	newInput(3, nodeValueSeed()).setShaderProp("seed");
	newInput(7, nodeValue_Rotation( "Phase",     0  )).setShaderProp("phase");
	newInput(4, nodeValue_Int(      "Iteration", 15 )).setShaderProp("iteration");
	
	////- =Transform
	newInput(1, nodeValue_Vec2( "Position", [0,0] )).setHotkey("G").setShaderProp("position");
	newInput(2, nodeValue_Vec2( "Scale",    [1,1] )).setHotkey("S").setShaderProp("scale");
	
	////- =Render
	newInput(5, nodeValue_Color(  "Color", ca_white          )).setShaderProp("color");
	newInput(6, nodeValue_Slider( "Gamma", 1, [ 0, 2, 0.01 ] )).setShaderProp("gamma");
	// input 9
	
	input_display_list = [ 
		["Output",     true], 0, 9, 10, 8, 
		["Noise",     false], 3, 7, 4, 
		["Transform", false], 1, 2, 
		["Render",    false], 5, 6, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _pos = getSingleValue(1);
		var  px  = _x + _pos[0] * _s;
		var  py  = _y + _pos[1] * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
}