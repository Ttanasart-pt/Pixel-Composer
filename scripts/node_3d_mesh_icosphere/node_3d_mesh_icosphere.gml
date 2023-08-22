function Node_3D_Mesh_Sphere_Ico(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name     = "3D Icosphere";
	
	object_class = __3dICOSphere;
	
	inputs[| in_mesh + 0] = nodeValue("Subdivision", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 );
	
	inputs[| in_mesh + 1] = nodeValue("Texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| in_mesh + 2] = nodeValue("Smooth Normal", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	input_display_list = [
		__d3d_input_list_mesh, in_mesh + 0, in_mesh + 2, 
		__d3d_input_list_transform,
		["Texture",	false], in_mesh + 1, 
	]
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _sub = _data[in_mesh + 0];
		var _tex = _data[in_mesh + 1];
		var _smt = _data[in_mesh + 2];
		
		var object = getObject(_array_index);
		object.checkParameter({level: _sub, smooth: _smt});
		object.texture = surface_texture(_tex);
		
		setTransform(object, _data);
		
		return object;
	} #endregion
	
	static getPreviewValues = function() { return array_safe_get(all_inputs, in_mesh + 1, noone); }
}