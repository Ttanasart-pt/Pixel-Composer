function Node_Gradient_Cube(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name = "Gradient Cube";
	shader = sh_gradient_cube;
	
	////- =Shape
	newInput( 5, nodeValue_EButton( "Shape",     0, [ "Cube", "Sphere" ] )).setShaderProp("shape");
	newInput( 1, nodeValue_Vec3(    "Rotation", [30,45,0] )).setShaderProp("camRotation");
	newInput( 2, nodeValue_Float(   "Scale",     1        )).setShaderProp("orthoScale");
	
	////- =Colors
	newInput( 3, nodeValue_Palette( "Colors",   [ca_black, ca_white]  )).setShaderProp("palette");
	newInput( 4, nodeValue_EButton( "Axis",      0, [ "X", "Y", "Z" ] )).setShaderProp("axis");
	newInput( 8, nodeValue_Vec3(    "Rotation", [0,0,0] )).setShaderProp("shapeRotation");
	newInput( 9, nodeValue_Vec3(    "Scale",    [1,1,1] )).setShaderProp("shapeScale");
	
	////- =Cross Section
	newInput( 6, nodeValue_EButton( "Axis",      0, [ "X", "Y", "Z" ] )).setShaderProp("crossAxis");
	newInput( 7, nodeValue_Slider(  "Position",  0                    )).setShaderProp("crossPosition");
	// 10
	
	newOutput(1, nodeValue_Output("Cross Section", VALUE_TYPE.surface, noone));
	
	input_display_list = [
		[ "Output",     true ],  0,
		[ "Shape",     false ],  5,  1,  2,  
		[ "Colors",    false ],  3,  4,  8,  9,  
		[ "Cross Section", false ],  6,  7, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		
	}
	
}