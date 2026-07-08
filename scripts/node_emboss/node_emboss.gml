function Node_Emboss(_x, _y, _group = noone) : Node_Shader_Processor(_x, _y, _group) constructor {
	name   = "Emboss";
	shader = sh_emboss;
	
	var i = shader_index;
	
	newInput(i+5, nodeValue_Surface(  "Override Color"    )).setShaderProp("baseBG");
	
	////- =Emboss
	newInput(i+0, nodeValue_Rotation( "Direction",    135 )).setShaderProp("direction");
	newInput(i+1, nodeValue_Float(    "Intensity",      1 )).setMappable(i+3).setShaderProp("intensity");
	newInput(i+2, nodeValue_Bool(     "Deboss",     false )).setShaderProp("deboss");
	
	////- =Rendering
	newInput(i+4, nodeValue_Color(    "Color",      ca_white )).setShaderProp("color");
	// i+6
	
	array_insert_after(input_display_list, 0, [i+5]);
	
	array_append(input_display_list, [ 
		[ "Emboss",    false ], i+0, i+1, i+3, i+2, 
		[ "Rendering", false ], i+4, 
	]);
	
}