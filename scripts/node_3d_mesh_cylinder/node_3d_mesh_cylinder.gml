function Node_3D_Mesh_Cylinder(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name     = "3D Cylinder";
	
	object_class = __3dCylinder;
	
	inputs[| in_mesh + 0] = nodeValue("Side", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 8 );
	
	inputs[| in_mesh + 1] = nodeValue("Texture Top", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| in_mesh + 2] = nodeValue("Texture Bottom", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| in_mesh + 3] = nodeValue("Texture Side", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| in_mesh + 4] = nodeValue("Smooth Side", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	input_display_list = [
		__d3d_input_list_mesh, in_mesh + 0, in_mesh + 4, 
		__d3d_input_list_transform,
		["Texture",	false], in_mesh + 1, in_mesh + 2, in_mesh + 3, 
	]
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _side = _data[in_mesh + 0];
		var _tex_top  = _data[in_mesh + 1];
		var _tex_bot  = _data[in_mesh + 2];
		var _tex_sid  = _data[in_mesh + 3];
		var _smt      = _data[in_mesh + 4];
		
		var object = getObject(_array_index);
		object.checkParameter({sides: _side, smooth: _smt});
		object.texture = [ surface_texture(_tex_top), surface_texture(_tex_bot), surface_texture(_tex_sid) ];
		
		setTransform(object, _data);
		
		return object;
	} #endregion
	
	static getPreviewValues = function() { return array_safe_get(all_inputs, in_mesh + 1, noone); }
}