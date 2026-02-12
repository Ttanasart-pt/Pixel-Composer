function Node_Symmetric_NN(_x, _y, _group = noone) : Node_Shader_Processor(_x, _y, _group) constructor {
	name   = "Symmetric NN";
	shader = sh_symmetric_nn;
	
	var i = shader_index;
	
	////- =Effect
	newInput(i+0, nodeValue_Float( "Radius",    4 )).setShaderProp("radius").setMappable(i+2);
	newInput(i+1, nodeValue_Float( "Intensity", 1 )).setShaderProp("intensity").setMappable(i+3);
	
	////- =Stylize
	// newInput(i+2, nodeValue_Bool( "Absolute", false )).setShaderProp("absolute");
	// i+4
	
	array_append(input_display_list, [ 
		[ "Effect", false ], i+0, i+2, i+1, i+4, 
		// [ "Stylize",   false ], i+2
	]);
	
	attribute_oversample();
}