function Node_Curvature(_x, _y, _group = noone) : Node_Shader_Processor(_x, _y, _group) constructor {
	name   = "Curvature";
	shader = sh_curvature;
	texFilter = true;
	
	var i = shader_index;
	
	////- =Curvature
	newInput(i+1, nodeValue_Float( "Radius",    2 )).setShaderProp("radius").setMappable(i+3);
	newInput(i+0, nodeValue_Float( "Intensity", 8 )).setShaderProp("intensity").setMappable(i+4);
	
	////- =Stylize
	newInput(i+2, nodeValue_Bool( "Absolute", false )).setShaderProp("absolute");
	// i+5
	
	array_append(input_display_list, [ 
		[ "Curvature", false ], i+1, i+3, i+0, i+4, 
		[ "Stylize",   false ], i+2
	]);
	
	attribute_oversample();
}