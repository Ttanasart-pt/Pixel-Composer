function Node_3D_Transform(_x, _y, _group = noone) : Node_3D_Object(_x, _y, _group) constructor {
	name  = "Transform";
	
	inputs[| in_d3d + 0] = nodeValue("Mesh", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Mesh, noone)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Mesh", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3Mesh, noone);
	
	input_display_list = [ in_d3d + 0, 
		["Transform", false], 0, 1, 2,
	];
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _mesh = _data[in_d3d + 0].clone();
		setTransform(_mesh, _data);
		
		return _mesh;
	} #endregion
}