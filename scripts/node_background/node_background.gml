function Node_Background(_x, _y, _group = noone) : Node_Shader_Processor(_x, _y, _group) constructor {
	name   = "Background";
	shader = sh_background;
	
	var i = shader_index;
	
	////- =Type
	newInput(i+0, nodeValue_Color("Color", ca_black )).setShaderProp("color");
	
	array_append(input_display_list, [ 
		[ "BG", false ], i+0 
	]);
	
}