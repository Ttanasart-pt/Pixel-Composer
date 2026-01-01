function Node_3D_Transform(_x, _y, _group = noone) : Node_3D_Object(_x, _y, _group) constructor {
	name   = "Transform 3D";
	
	newInput(in_d3d + 0, nodeValue_D3Mesh("Mesh" ));
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.d3Mesh, noone));
	
	input_display_list = [ in_d3d + 0, 
		["Transform", false], 0, 1, 2,
	];
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		var _mesh = _data[in_d3d + 0];
		if(!is(_mesh, __3dInstance)) return noone;
		
		var _scene = new __3dTransformed(_mesh);
		setTransform(_scene, _data);
		
		return _scene;
	}
}