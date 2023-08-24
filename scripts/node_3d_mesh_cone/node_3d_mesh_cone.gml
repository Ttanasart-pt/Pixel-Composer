function Node_3D_Mesh_Cone(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "3D Cone";
	
	object_class = __3dCone;
	
	inputs[| in_mesh + 0] = nodeValue("Side", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 8 );
	
	inputs[| in_mesh + 1] = nodeValue("Material Bottom", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Material, noone );
	
	inputs[| in_mesh + 2] = nodeValue("Material Side", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Material, noone );
	
	inputs[| in_mesh + 3] = nodeValue("Smooth Side", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	input_display_list = [
		__d3d_input_list_mesh, in_mesh + 0, in_mesh + 3, 
		__d3d_input_list_transform,
		["Material",	false], in_mesh + 1, in_mesh + 2, 
	]
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _side     = _data[in_mesh + 0];
		var _mat_bot  = _data[in_mesh + 1];
		var _mat_sid  = _data[in_mesh + 2];
		var _smt      = _data[in_mesh + 3];
		
		var object = getObject(_array_index);
		object.checkParameter({sides: _side, smooth: _smt});
		object.materials = [ _mat_bot, _mat_sid ];
		
		setTransform(object, _data);
		
		return object;
	} #endregion
	
	static getPreviewValues = function() { return array_safe_get(all_inputs, in_mesh + 1, noone); }
}