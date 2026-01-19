function Node_3D_Get_Data(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name   = "3D Get Data";
	setDimension(96, 48);
	setDrawIcon(s_node_3d_get_data);
	
	newInput(0, nodeValue_D3Mesh("Mesh"));
	
	newOutput(0, nodeValue_Output("Origin",   VALUE_TYPE.float, [0,0,0]   )).setDisplay(VALUE_DISPLAY.vector);
	newOutput(1, nodeValue_Output("Position", VALUE_TYPE.float, [0,0,0]   )).setDisplay(VALUE_DISPLAY.vector);
	newOutput(2, nodeValue_Output("Rotation", VALUE_TYPE.float, [0,0,0,1] )).setDisplay(VALUE_DISPLAY.d3quarternion);
	newOutput(3, nodeValue_Output("Scale",    VALUE_TYPE.float, [0,0,0]   )).setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [ 0, 
		["Transform", false], 
	];
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		var _mesh = _data[0];
		if(!is(_mesh, __3dInstance)) return _output;
		
		_output[0] = _mesh.transform.anchor.toArray();
		_output[1] = _mesh.transform.position.toArray();
		_output[2] = _mesh.transform.rotation.ToArray();
		_output[3] = _mesh.transform.scale.toArray();
		
		return _output;
	}
	
	static getPreviewObject = function() /*=>*/ {return getInputSingle(0)};
}