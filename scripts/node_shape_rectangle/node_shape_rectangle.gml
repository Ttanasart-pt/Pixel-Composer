function Node_Shape_Rectangle(_x, _y, _group = noone) : Node_Shape_Single(_x, _y, _group) constructor {
	name   = "Draw Rectangle";
	shader = sh_shape_rectangle;
	
	var i = input_shape_index;
	
	////- =Geometry
	newInput(i+0, nodeValue_Slider( "Corner", 0 ));
	// 
	
	array_append(input_display_list, [
		[ "Geometry", false ], i+0, 
	]);
	
	array_append(input_display_list, input_display_render);
	
	////- Nodes
	
	static submitShapeShader = function(_data) {
		var i = input_shape_index;
		
		shader_set_f( "corner", _data[i+0] );
	}
}
