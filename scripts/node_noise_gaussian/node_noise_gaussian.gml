function Node_Noise_Gaussian(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Gaussian Noise";
	shader = sh_noise_gaussian;
	
	newInput( 1, nodeValueSeed()).setShaderProp("seed");
	
	////- =Noise
	newInput( 2, nodeValue_Vec2(    "Position", [0,0] )).setShaderProp("position");
	newInput( 3, nodeValue_Rotation("Rotation",  0    )).setShaderProp("rotation");
	newInput( 4, nodeValue_Vec2(    "Scale",    [1,1] )).setShaderProp("scale");
	
	newInput( 6, nodeValue_Slider(  "Mean",      .5   )).setShaderProp("mean");
	newInput( 7, nodeValue_Slider(  "Varience",  .5   )).setShaderProp("varience");
	
	////- =Conversion
	newInput( 8, nodeValue_Bool(    "Use Conversion", false )).setShaderProp("convertMode");
	newInput( 9, nodeValue_Surface( "Conv. surf 1"          )).setShaderProp("convertSurface1");
	newInput(10, nodeValue_Surface( "Conv. surf 2"          )).setShaderProp("convertSurface2");
	
	////- =Rendering
	newInput( 5, nodeValue_SliRange( "Level",   [0,1] )).setShaderProp("level");
	// 11
	
	input_display_list = [ 1, 
		[ "Output",      true    ],  0,
		[ "Noise",      false    ],  2,  3,  4,  6,  7,  
		[ "Conversion", false, 8 ],  9, 10, 
		[ "Rendering",  false    ],  5,
	];
	
	////- Nodes
	
	attribute_surface_depth();
	
	static onProcessData = function(_outSurf, _data, _array_index) {
		
	}
	
}