function Node_Cellular_Cube(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name = "Cellular Cube";
	shader = sh_cellular_cube;
	
	newInput( 7, nodeValueSeed()).setShaderProp("seed");
	
	////- =Shape
	newInput( 1, nodeValue_EButton( "Shape",     0, [ "Cube", "Sphere" ] )).setShaderProp("shape");
	newInput( 2, nodeValue_Vec3(    "Rotation", [30,45,0] )).setShaderProp("camRotation");
	newInput( 3, nodeValue_Float(   "Scale",     1        )).setShaderProp("orthoScale");
	
	////- =Noise
	newInput( 6, nodeValue_EButton( "Axis",      0, [ "X", "Y", "Z" ] )).setShaderProp("axis");
	newInput(12, nodeValue_Vec3(    "Position", [0,0,0] )).setShaderProp("perlinPosition");
	newInput( 8, nodeValue_Vec3(    "Rotation", [0,0,0] )).setShaderProp("shapeRotation");
	newInput( 9, nodeValue_Vec3(    "Scale",    [1,1,1] )).setShaderProp("shapeScale");
	
	newInput(10, nodeValue_Float( "Noise Scale", 8 )).setShaderProp("perlinScale");
	newInput(11, nodeValue_Int(   "Iteration",   1 )).setShaderProp("perlinIteration");
	
	////- =Rendering
	newInput(13, nodeValue_SliRange( "Level",         [0,1] )).setShaderProp("renderLevel");
	
	////- =Cross Section
	newInput( 4, nodeValue_EButton( "Axis",      0, [ "X", "Y", "Z" ] )).setShaderProp("crossAxis");
	newInput( 5, nodeValue_Slider(  "Position",  0                    )).setShaderProp("crossPosition");
	// 14
	
	newOutput(1, nodeValue_Output("Cross Section", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 7, 
		[ "Output",     true ],  0,
		[ "Shape",     false ],  1,  2,  3, 
		[ "Noise",     false ],  6, 12,  8,  9, 10, 11, 
		[ "Rendering", false ], 13, 
		[ "Cross Section", false ],  4,  5, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		
	}
	
}