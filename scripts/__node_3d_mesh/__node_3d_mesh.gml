function Node_3D_Mesh(_x, _y, _group = noone) : Node_3D_Object(_x, _y, _group) constructor {
	name = "3D Mesh";
	
	in_mesh = ds_list_size(inputs);
	
	outputs[| 0] = nodeValue("Mesh", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3Mesh, noone);
	
	#macro __d3d_input_list_mesh ["Mesh", false]
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {}
}