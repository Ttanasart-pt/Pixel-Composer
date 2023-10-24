function Node_3D_Modifier(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name = "3D Mesh Modifier";
	
	inputs[| 0] = nodeValue("Mesh", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Mesh, noone)
		.setVisible(true, true);
	
	in_mesh = ds_list_size(inputs);
	
	outputs[| 0] = nodeValue("Mesh", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3Mesh, noone);
	
}