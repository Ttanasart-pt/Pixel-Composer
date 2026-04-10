function Node_Line_Match(_x, _y, _group = noone) : Node_Shader_Processor(_x, _y, _group) constructor {
	name   = "Line Match";
	shader = sh_line_match;
	
	var i = shader_index;
	
	////- =Matching
	newInput(i+0, nodeValue_Int(   "Radius",   4     )).setShaderProp("iradius");
	newInput(i+3, nodeValue_Bool(  "Fade",     false )).setShaderProp("fade");
	newInput(i+4, nodeValue_Bool(  "One Side", false )).setShaderProp("oneSide");
	
	////- =Rendering
	newInput(i+1, nodeValue_Float( "Intensity", 1        )).setShaderProp("intensity");
	newInput(i+2, nodeValue_Color( "Blending",  ca_white )).setShaderProp("color");
	
	array_append(input_display_list, [ 
		[ "Matching",  false ], i+0, i+3, i+4, 
		[ "Rendering", false ], i+1, i+2, 
	]);
	
}