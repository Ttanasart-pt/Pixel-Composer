function Node_3D_Mesh_Plane(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name     = "3D Plane";
	
	object_class = __3dPlane;
	
	inputs[| in_mesh + 0] = nodeValue("Material", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Material, new __d3dMaterial() )
		.setVisible(true, true);
	
	inputs[| in_mesh + 1] = nodeValue("Normal", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2 )
		.setDisplay(VALUE_DISPLAY.enum_button, [ "X", "Y", "Z" ]);
	
	inputs[| in_mesh + 2] = nodeValue("Both side", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false )
	
	inputs[| in_mesh + 3] = nodeValue("Back Material", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Material, new __d3dMaterial() )
	
	input_display_list = [
		__d3d_input_list_mesh, in_mesh + 1, 
		__d3d_input_list_transform,
		["Material",	false], in_mesh + 2, in_mesh + 0, in_mesh + 3, 
	]
	
	static step = function() {
		var _both = getSingleValue(in_mesh + 2);
		inputs[| in_mesh + 3].setVisible(_both, _both);
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _mat  = _data[in_mesh + 0];
		var _axs  = _data[in_mesh + 1];
		var _both = _data[in_mesh + 2];
		var _bmat = _data[in_mesh + 3];
		
		var object = getObject(_array_index);
		object.checkParameter({ normal: _axs, two_side: _both });
		object.materials = _both? [ _mat, _bmat ] : [ _mat ];
		
		setTransform(object, _data);
		
		return object;
	} #endregion
	
	static getPreviewValues = function() { return array_safe_get_fast(all_inputs, in_mesh + 0, noone); }
}