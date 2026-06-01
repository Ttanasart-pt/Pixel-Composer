function Node_Surface_Cube(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name = "Surface Cube";
	shader = sh_surface_cube;
	
	newInput( 7, nodeValueSeed()).setShaderProp("seed");
	
	////- =Shape
	newInput( 1, nodeValue_EButton( "Shape",     0, [ "Cube", "Sphere" ] )).setShaderProp("shape");
	newInput( 2, nodeValue_Vec3(    "Rotation", [30,45,0] )).setShaderProp("camRotation");
	newInput( 3, nodeValue_Float(   "Scale",     1        )).setShaderProp("orthoScale");
	
	////- =Surfaces
	newInput( 6, nodeValue_EButton( "Axis",      0, [ "X", "Y", "Z" ] )).setShaderProp("axis");
	newInput( 8, nodeValue_Vec3(    "Rotation", [0,0,0] )).setShaderProp("shapeRotation");
	newInput( 9, nodeValue_Vec3(    "Scale",    [1,1,1] )).setShaderProp("shapeScale");
	
	newInput(10, nodeValue_Surface( "Surface 1" )).setShaderProp("surface1");
	newInput(11, nodeValue_Surface( "Surface 2" )).setShaderProp("surface2");
	
	////- =Cross Section
	newInput( 4, nodeValue_EButton( "Axis",      0, [ "X", "Y", "Z" ] )).setShaderProp("crossAxis");
	newInput( 5, nodeValue_Slider(  "Position",  0                    )).setShaderProp("crossPosition");
	// 12
	
	newOutput(1, nodeValue_Output("Cross Section", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 7, 
		[ "Output",     true ],  0,
		[ "Shape",     false ],  1,  2,  3, 
		[ "Noise",     false ],  6,  8,  9, 10, 11, 
		[ "Cross Section", false ],  4,  5, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		
	}
	
}