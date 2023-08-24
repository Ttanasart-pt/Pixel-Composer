function Node_3D_Mesh_Plane(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name     = "3D Plane";
	
	object_class = __3dPlane;
	
	inputs[| in_mesh + 0] = nodeValue("Material", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Material, noone );
	
	inputs[| in_mesh + 1] = nodeValue("Normal", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2 )
		.setDisplay(VALUE_DISPLAY.enum_button, [ "X", "Y", "Z" ]);
	
	input_display_list = [
		__d3d_input_list_mesh, in_mesh + 1, 
		__d3d_input_list_transform,
		["Material",	false], in_mesh + 0, 
	]
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _mat = _data[in_mesh + 0];
		var _axs = _data[in_mesh + 1];
		
		var object = getObject(_array_index);
		object.checkParameter({normal: _axs});
		object.materials = [ _mat ];
		
		setTransform(object, _data);
		
		return object;
	} #endregion
	
	static getPreviewValues = function() { return array_safe_get(all_inputs, in_mesh + 0, noone); }
}