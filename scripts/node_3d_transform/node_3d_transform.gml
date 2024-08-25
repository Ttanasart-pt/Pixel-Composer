function Node_3D_Transform(_x, _y, _group = noone) : Node_3D_Object(_x, _y, _group) constructor {
	name  = "Transform";
	
	newInput(in_d3d + 0, nodeValue_D3Mesh("Mesh", self, noone))
		.setVisible(true, true);
	
	outputs[0] = nodeValue_Output("Mesh", self, VALUE_TYPE.d3Mesh, noone);
	
	input_display_list = [ in_d3d + 0, 
		["Transform", false], 0, 1, 2,
	];
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {
		var _mesh = _data[in_d3d + 0];
		
		var _scene = new __3dGroup();
		if(!is_struct(_mesh)) return _scene;
		
		setTransform(_scene, _data);
		_scene.addObject(_mesh);
		
		return _scene;
	}
}