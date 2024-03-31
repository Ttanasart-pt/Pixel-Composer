function Node_3D_Mesh_Sphere_UV(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name     = "3D UV Sphere";
	
	object_class = __3dUVSphere;
	
	inputs[| in_mesh + 0] = nodeValue("Horizontal Slices", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 8 );
	
	inputs[| in_mesh + 1] = nodeValue("Vertical Slices", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 16 );
	
	inputs[| in_mesh + 2] = nodeValue("Material", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Material, noone )
		.setVisible(true, true);
	
	inputs[| in_mesh + 3] = nodeValue("Smooth Normal", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	input_display_list = [
		__d3d_input_list_mesh, in_mesh + 0, in_mesh + 1, in_mesh + 3, 
		__d3d_input_list_transform,
		["Material",	false], in_mesh + 2, 
	]
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _sideH = _data[in_mesh + 0];
		var _sideV = _data[in_mesh + 1];
		var _mat   = _data[in_mesh + 2];
		var _smt   = _data[in_mesh + 3];
		
		var object = getObject(_array_index);
		object.checkParameter({ hori: _sideH, vert: _sideV, smooth: _smt });
		object.materials = [ _mat ];
		
		setTransform(object, _data);
		
		return object;
	} #endregion
	
	static getPreviewValues = function() { return array_safe_get_fast(all_inputs, in_mesh + 1, noone); }
}