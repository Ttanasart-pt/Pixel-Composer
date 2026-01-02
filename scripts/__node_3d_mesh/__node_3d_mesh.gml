#macro __d3d_input_list_mesh ["Mesh", false]

function Node_3D_Mesh(_x, _y, _group = noone) : Node_3D_Object(_x, _y, _group) constructor {
	name    = "3D Mesh";
	in_mesh = array_length(inputs);
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.d3Mesh, noone));
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {}
	
	static getPreviewValues = function() /*=>*/ {return outputs[0].getValue()};
}