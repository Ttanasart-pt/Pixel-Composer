function Node_3D_Mesh_Extrude(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name     = "Surface Extrude";
	
	object_class = __3dSurfaceExtrude;
	
	inputs[| in_mesh + 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Material, noone);
	
	inputs[| in_mesh + 1] = nodeValue("Height map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| in_mesh + 2] = nodeValue("Smooth", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
	
	inputs[| in_mesh + 3] = nodeValue("Always update", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	input_display_list = [
		__d3d_input_list_mesh,
		__d3d_input_list_transform,
		["Extrude",	false], in_mesh + 0, in_mesh + 1, in_mesh + 3, 
	]
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _mat  = _data[in_mesh + 0];
		var _hght = _data[in_mesh + 1];
		var _smt  = _data[in_mesh + 2];
		var _updt = _data[in_mesh + 3];
		var _surf = _mat == noone? noone : _mat.surface;
		
		var object = getObject(_array_index);
		object.checkParameter({surface: _surf, height: _hght, smooth: _smt}, _updt);
		object.materials = [ _mat ];
		
		setTransform(object, _data);
		
		return object;
	} #endregion
	
	static getPreviewValues = function() { return array_safe_get(all_inputs, in_mesh + 0, noone); }
}