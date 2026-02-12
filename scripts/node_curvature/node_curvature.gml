function Node_Curvature(_x, _y, _group = noone) : Node_Shader_Processor(_x, _y, _group) constructor {
	name   = "Curvature";
	shader = sh_curvature;
	texFilter = true;
	
	var i = shader_index;
	
	////- =Curvature
	newInput(i+1, nodeValue_Float( "Radius",    2 )).setShaderProp("radius");
	newInput(i+0, nodeValue_Float( "Intensity", 8 )).setShaderProp("intensity");
	
	////- =Stylize
	newInput(i+2, nodeValue_Bool( "Absolute", false )).setShaderProp("absolute");
	
	array_append(input_display_list, [ 
		[ "Curvature", false ], i+1, i+0,
		[ "Stylize",   false ], i+2
	]);
	
	attribute_oversample();
}