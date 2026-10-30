function Node_3D_Mesh_Convex_Hull(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name     = "3D Convex Hull";
	
	object_class = __3dConvexHull;
	var i = in_mesh;
	
	////- =Mesh
	newInput(i+1, nodeValue_Vec2( "Points", [] )).setVisible(true, true).setArrayDepth(1);
	
	////- =Material
	newInput(i+0, nodeValue_D3Material( "Material", new __d3dMaterial() )).setVisible(true, true);
	// input i=2
	
	input_display_list = [
		__d3d_input_list_transform,
		[ "Mesh",     false ], i+1, 
		[ "Material", false ], i+0, 
	]
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		var _mat  = _data[in_mesh + 0];
		var _pnts = _data[in_mesh + 1];
		
		var object = getObject(_array_index);
		
		object.checkParameter({ points: _pnts });
		object.materials   = [ _mat ];
		
		setTransform(object, _data);
		
		return object;
	}
	
}