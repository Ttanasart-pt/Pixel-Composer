function Node_3D_Modifier(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name = "3D Mesh Modifier";
	
	inputs[| 0] = nodeValue("Mesh", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Mesh, noone)
		.setVisible(true, true);
	
	in_mesh = ds_list_size(inputs);
	
	outputs[| 0] = nodeValue("Mesh", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3Mesh, noone);
	
	static modify_object = function(_object, _data, _matrix) { #region
		return _object;
	} #endregion
	
	static modify_group = function(_group, _data, _matrix) { #region
		var _gr = new __3dGroup();
		
		_gr.transform = _group.transform.clone();
		_gr.transform.submitMatrix();
		_gr.transform.clearMatrix();
		_matrix = _matrix.Mul(_gr.transform.matrix);
		
		for( var i = 0, n = array_length(_group.objects); i < n; i++ )
			_gr.objects[i] = modify(_group.objects[i], _data, _matrix);
		
		return _gr;
	} #endregion
	
	static modify = function(_object, _data, _matrix = new BBMOD_Matrix()) { #region
		if(is_instanceof(_object, __3dObject)) return modify_object(_object, _data, _matrix);
		if(is_instanceof(_object, __3dGroup))  return modify_group(_object, _data, _matrix);
		
		return noone;
	} #endregion
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		return modify(_data[0], _data);
	} #endregion
}