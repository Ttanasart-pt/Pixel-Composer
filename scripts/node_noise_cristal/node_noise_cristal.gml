function Node_Noise_Cristal(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Cristal Noise";
	shader = sh_noise_cristal;
	
	////- =Output
	
	newInput(8, nodeValue_Surface("Mask"));
	
	////- =Noise
	
	newInput(3, nodeValueSeed()).setShaderProp("seed");
	newInput(7, nodeValue_Rotation( "Phase",     0  )).setShaderProp("phase");
	newInput(4, nodeValue_Int(      "Iteration", 15 )).setShaderProp("iteration");
	
	////- =Transform
	
	newInput(1, nodeValue_Vec2( "Position", [0,0] )).setShaderProp("position");
	newInput(2, nodeValue_Vec2( "Scale",    [1,1] )).setShaderProp("scale");
	
	////- =Render
	
	newInput(5, nodeValue_Color(  "Color", ca_white          )).setShaderProp("color");
	newInput(6, nodeValue_Slider( "Gamma", 1, [ 0, 2, 0.01 ] )).setShaderProp("gamma");
	
	input_display_list = [ 
		["Output",     true], 0, 8, 
		["Noise",     false], 3, 7, 4, 
		["Transform", false], 1, 2, 
		["Render",    false], 5, 6, 
	];
}