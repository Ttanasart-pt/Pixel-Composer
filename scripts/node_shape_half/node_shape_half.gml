function Node_Shape_Half(_x, _y, _group = noone) : Node_Shape_Single(_x, _y, _group) constructor {
	name   = "Draw Half";
	shader = sh_shape_half;
	
	var i = input_shape_index;
	
	////- =Geometry
	
	// 
	
	array_append(input_display_list, [
		// [ "Geometry", false ], 
	]);
	
	array_append(input_display_list, input_display_render);
	
	////- Nodes
	
	static submitShapeShader = function(_data) {
		var i = input_shape_index;
		
		// shader_set_f( "corner", _data[i+0] );
	}
}
