function Node_UV_Height(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "UV Height";
	shader = sh_uv_height;
	shader_interpolate = true;
	
	////- =Output
	newInput( 1, nodeValue_Surface( "UV Map"     ));
	newInput( 2, nodeValue_Slider(  "UV Mix", 1  ));
	newInput( 3, nodeValue_Surface( "Mask"       ));
	
	////- =Height Map
	newInput( 4, nodeValue_Surface( "Height Map"      )).setShaderProp("heightMap");
	newInput( 5, nodeValue_Vec2(    "Position", [0,0] )).setUnitSimple().setShaderProp("position");
	newInput( 7, nodeValue_Slider(  "Strength",  1, [-4,4,.01] )).setShaderProp("intensity");
	
	////- =Channels
	newInput( 6, nodeValue_Slider( "Blue", 0 )).setShaderProp("blue");
	// 8
	
	input_display_list = [
		[ "Output",      true ],  0,  1,  2,  3, 
		[ "Height Map", false ],  4,  5,  7,  
		[ "Channels",   false ],  6, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		InputDrawOverlay(inputs[5].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my));
	}
	
}