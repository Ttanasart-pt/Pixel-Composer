function Node_Multiply_Alpha(_x, _y, _group = noone) : Node_Shader_Processor(_x, _y, _group) constructor {
	name   = "Multiply Alpha";
	shader = sh_multiply_alpha;
	
	var i = shader_index;
	
	////- =Preprocess
	newInput(i+0, nodeValue_Slider("Threshold", 0)).setShaderProp("threshold");
	
	////- =Multiply
	newInput(i+1, nodeValue_Color("BG Color", ca_white)).setShaderProp("bgColor");
	
	array_append(input_display_list, [ 
		[ "Preprocess", false ], i+0,
		[ "Multiply",   false ], i+1,
	]);
	
}