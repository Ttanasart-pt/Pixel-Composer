function Node_3D_Mesh_Cone(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "3D Cone";
	object_class = __3dCone;
	
	var i = in_mesh;
	newInput(i+0, nodeValue_Int("Side", 8 )).setValidator(VV_min(3));
	
	////- =Material
	newInput(i+3, nodeValue_Bool("Smooth Side", false ));
	newInput(i+1, nodeValue_D3Material("Material Bottom", new __d3dMaterial())).setVisible(true, true);
	newInput(i+2, nodeValue_D3Material("Material Side", new __d3dMaterial())).setVisible(true, true);
	// i+4
	
	input_display_list = [
		__d3d_input_list_mesh, i+0, 
		__d3d_input_list_transform,
		["Material",	false], i+3, i+1, i+2, 
	]
	
	static processData = function(_output, _data, _array_index = 0) {
		var _side     = _data[in_mesh + 0];
		var _mat_bot  = _data[in_mesh + 1];
		var _mat_sid  = _data[in_mesh + 2];
		var _smt      = _data[in_mesh + 3];
		
		var object = getObject(_array_index);
		object.checkParameter({sides: _side, smooth: _smt});
		object.materials = [ _mat_bot, _mat_sid ];
		
		setTransform(object, _data);
		
		return object;
	}
	
	static getPreviewValues = function() { return getSingleValue(in_mesh + 1); }
}