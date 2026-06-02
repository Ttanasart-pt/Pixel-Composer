function Node_Linearize(_x, _y, _group = noone) : Node_Shader_Processor(_x, _y, _group) constructor {
	name   = "Hough Extrude";
	shader = sh_linearize;
	
	var i = shader_index;
	
	////- =Linearize
	newInput(i+4, nodeValue_EScroll( "Shape",    0, [ "Rectangle", "Circle", "Diamond" ] )).setShaderProp("shape");
	newInput(i+0, nodeValue_Int(   "Radius",     4 )).setShaderProp("iradius").setPieMenu();
	newInput(i+2, nodeValue_Int(   "Resolution", 4 )).setShaderProp("iresolution");
	
	////- =Rendering
	newInput(i+1, nodeValue_Float(  "Intensity", 1 )).setShaderProp("intensity").setPieMenu();
	newInput(i+3, nodeValue_Slider( "Shift",     0 )).setShaderProp("shift");
	// i+5
	
	array_append(input_display_list, [ 
		[ "Linearize", false ], i+4, i+0, i+2,  
		[ "Rendering", false ], i+1, i+3, 
	]);
	
	attribute_oversample();
	
}