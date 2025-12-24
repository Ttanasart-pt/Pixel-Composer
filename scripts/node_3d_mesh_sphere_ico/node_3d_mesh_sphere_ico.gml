function Node_3D_Mesh_Sphere_Ico(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name     = "3D Icosphere";
	
	object_class = __3dICOSphere;
	
	newInput(in_mesh + 0, nodeValue_Int("Subdivision", 1 ))
		.setValidator(VV_min(0));
	
	newInput(in_mesh + 1, nodeValue_D3Material("Material", new __d3dMaterial()))
		.setVisible(true, true);
	
	newInput(in_mesh + 2, nodeValue_Bool("Smooth Normal", false ));
	
	input_display_list = [
		__d3d_input_list_mesh, in_mesh + 0, 
		__d3d_input_list_transform,
		["Material",	false], in_mesh + 2, in_mesh + 1, 
	]
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		var _sub = _data[in_mesh + 0];
		var _mat = _data[in_mesh + 1];
		var _smt = _data[in_mesh + 2];
		
		var object = getObject(_array_index);
		object.checkParameter({ level: _sub, smooth: _smt });
		object.materials = [ _mat ];
		
		setTransform(object, _data);
		
		return object;
	}
	
	static getPreviewValues = function() { return getInputSingle(in_mesh + 1); }
}