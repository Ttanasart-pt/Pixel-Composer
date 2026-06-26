function Node_Shape_Ellipse(_x, _y, _group = noone) : Node_Shape_Single(_x, _y, _group) constructor {
	name   = "Draw Ellipse";
	shader = sh_shape_ellipse;
	
	var i = input_shape_index;
	
	////- =Geometry
	// 
	
	array_append(input_display_list, [
		
	]);
	
	array_append(input_display_list, input_display_render);
	
	////- Nodes
	
	static submitShapeShader = function(_data) {
		var i = input_shape_index;
		
	}
}
