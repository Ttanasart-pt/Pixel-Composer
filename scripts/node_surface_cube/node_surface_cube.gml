function Node_Surface_Cube(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name = "Surface Cube";
	shader = sh_surface_cube;
	
	////- =View
	newInput( 1, nodeValue_Vec3(  "Rotation",   [30,45,0] )).setShaderProp("camRotation");
	newInput( 2, nodeValue_Float( "Scale",       1        )).setShaderProp("orthoScale");
	
	////- =Surface
	newInput( 4, nodeValue_EButton( "Axis",   0, [ "X", "Y", "Z" ] )).setShaderProp("axis");
	newInput( 3, nodeValue_Palette( "Colors", [ca_black, ca_white] )).setShaderProp("palette");
	// 
	
	input_display_list = [
		[ "Output",  true ],  0,
		[ "View",   false ],  1,  2,  
		[ "Colors", false ],  4,  3, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		
	}
	
}