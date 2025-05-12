function Node_3D_Mesh_Plane(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "3D Plane";
	object_class = __3dPlane;
	
	newInput(in_mesh + 0, nodeValue_D3Material("Material", self, new __d3dMaterial()))
		.setVisible(true, true);
	
	newInput(in_mesh + 1, nodeValue_Enum_Button("Normal", self,  2 , [ "X", "Y", "Z" ]));
	
	newInput(in_mesh + 2, nodeValue_Bool("Both side", self, false ))
		.rejectArray();
	
	newInput(in_mesh + 3, nodeValue_D3Material("Back Material", self, new __d3dMaterial()))
	
	input_display_list = [
		__d3d_input_list_mesh, in_mesh + 1, 
		__d3d_input_list_transform,
		["Material",	false], in_mesh + 2, in_mesh + 0, in_mesh + 3, 
	]
	
	static preGetInputs = function() {
		var _both = inputs[in_mesh + 2].getValue();
		
		inputs[in_mesh + 3].setVisible(_both, _both);
	}
	
	static processData = function(_output, _data, _array_index = 0) {
		var _mat  = _data[in_mesh + 0];
		var _axs  = _data[in_mesh + 1];
		var _both = _data[in_mesh + 2];
		var _bmat = _data[in_mesh + 3];
		
		var object = getObject(_array_index);
		object.checkParameter({ normal: _axs, two_side: _both });
		object.materials = _both? [ _mat, _bmat ] : [ _mat ];
		
		setTransform(object, _data);
		
		return object;
	}
	
	static getPreviewValues = function() { return getSingleValue(in_mesh + 0); }
}