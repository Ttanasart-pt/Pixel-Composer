function Node_3D_Mesh_Plane(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name     = "3D Plane";
	
	object_class = __3dPlane();
	
	inputs[| in_mesh + 0] = nodeValue("Texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	input_display_list = [
		__d3d_input_list_mesh,
		__d3d_input_list_transform,
		["Texture",	false], in_mesh + 0, 
	]
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _tex = _data[in_mesh + 0];
		
		var object;
		
		object = getObject(_array_index, __3dCube);
		object.texture = surface_texture(_tex);
		
		setTransform(object, _data);
		
		return object;
	} #endregion
	
	static getPreviewValues = function() { return array_safe_get(all_inputs, in_mesh + 0, noone); }
}